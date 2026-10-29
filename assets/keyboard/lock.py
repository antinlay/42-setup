#!/usr/bin/python3
"""Temporarily restrict GNOME to English before the campus locker."""
import ast
import fcntl
import json
import os
from pathlib import Path
import subprocess
import sys
import time

root = Path(__file__).resolve().parent
pending = root / 'sources-before-lock.json'
env = os.environ.copy()
env.pop('XDG_CONFIG_HOME', None)
env['GIO_EXTRA_MODULES'] = '/usr/lib/x86_64-linux-gnu/gio/modules'
schema = 'org.gnome.desktop.input-sources'
from display import snapshot_display, apply_display

def get(key):
    return subprocess.check_output(['/usr/bin/gsettings', 'get', schema, key], env=env, text=True).strip()

def put(key, value):
    subprocess.run(['/usr/bin/gsettings', 'set', schema, key, value], env=env, check=True)

def children():
    found = set()
    for path in Path('/proc').glob('[0-9]*/cmdline'):
        try:
            status = (path.parent / 'status').read_text()
            uid_line = next(line for line in status.splitlines() if line.startswith('Uid:'))
            if int(uid_line.split()[1]) != os.getuid():
                continue
            command = path.read_bytes().split(b'\0')[0]
            if command.startswith(b'[ft_ld]'):
                pid = path.parent.name
                found.update(int(p) for p in (path.parent / 'task' / pid / 'children').read_text().split())
        except (OSError, ValueError):
            pass
    return found

def restore():
    if children():
        sys.exit('Экран блокировки активен; восстановление раскладок отложено.')
    if pending.exists():
        original = json.loads(pending.read_text())
        put('sources', original['sources'])
        put('mru-sources', original['mru-sources'])
        try:
            apply_display(original.get('display'))
        except Exception as error:
            # Display recovery must never block keyboard recovery across hosts.
            archive = root / 'display-recovery-skipped.json'
            archive.write_text(json.dumps(original))
            archive.chmod(0o600)
            print(f'Display recovery skipped: {error}', file=sys.stderr)
        pending.unlink()
        print('Исходные раскладки восстановлены.')

guard = open(root / 'lock-request', 'a')
try:
    fcntl.flock(guard, fcntl.LOCK_EX | fcntl.LOCK_NB)
except BlockingIOError:
    sys.exit(0)
if '--restore' in sys.argv:
    restore()
    sys.exit(0)
if children():
    sys.exit('Программа блокировки уже активна.')

# Wait for modifier keys to be released, without recording any keystrokes.
import ctypes
x = ctypes.CDLL('libX11.so.6')
x.XOpenDisplay.argtypes = [ctypes.c_char_p]
x.XOpenDisplay.restype = ctypes.c_void_p
x.XQueryKeymap.argtypes = [ctypes.c_void_p, ctypes.c_void_p]
x.XCloseDisplay.argtypes = [ctypes.c_void_p]
display = x.XOpenDisplay(None)
if not display:
    sys.exit('Нет соединения с X11; экран не блокируется.')
keys = ctypes.create_string_buffer(32)
deadline = time.monotonic() + 10
while True:
    x.XQueryKeymap(display, keys)
    if not any(keys.raw):
        break
    if time.monotonic() > deadline:
        sys.exit('Клавиши остаются зажатыми; экран не блокируется.')
    time.sleep(0.05)
x.XCloseDisplay(display)
time.sleep(0.4)

if not pending.exists():
    original = {'sources': get('sources'), 'mru-sources': get('mru-sources'),
                'display': snapshot_display()}
    temporary = root / 'sources-before-lock.tmp'
    temporary.write_text(json.dumps(original))
    temporary.chmod(0o600)
    temporary.replace(pending)
else:
    original = json.loads(pending.read_text())
sources = ast.literal_eval(original['sources'])
english = next((source for source in sources if source[0] == 'xkb' and source[1].split('+')[0] in ('us', 'gb')), None)
if english is None:
    sys.exit('Не найдена английская US/UK-раскладка; экран не блокируется.')
put('sources', repr([english]))
put('mru-sources', repr([english]))
deadline = time.monotonic() + 5
while True:
    query = subprocess.check_output(['/usr/bin/setxkbmap', '-query'], text=True)
    layouts = next((line.split(':', 1)[1].strip().split(',') for line in query.splitlines() if line.startswith('layout:')), [])
    if layouts and all(layout in ('us', 'gb') for layout in layouts):
        break
    if time.monotonic() > deadline:
        restore()
        sys.exit('Не удалось подтвердить английскую карту; экран не блокируется.')
    time.sleep(0.1)
print('Подтверждено: GNOME и активная карта X11 содержат только английский.', flush=True)
if '--prepare-only' in sys.argv:
    sys.exit(0)

if not os.access('/usr/share/42/ft_lock', os.X_OK):
    restore()
    sys.exit('Программа ft_lock отсутствует.')
try:
    apply_display(original.get('display'), 2.0)
    time.sleep(0.4)
    process = subprocess.Popen(['/usr/share/42/ft_lock'])
except BaseException:
    restore()
    raise
observed = set()
deadline = time.monotonic() + 10
while time.monotonic() < deadline:
    observed.update(children())
    if observed:
        break
    time.sleep(0.1)
if observed:
    while children().intersection(observed):
        time.sleep(0.5)
    time.sleep(0.5)
    restore()
else:
    print('Не удалось отследить окно блокировки. Английский сохранён для безопасного ввода; после разблокирования нажми Command+Alt+R.', flush=True)
process.wait()
