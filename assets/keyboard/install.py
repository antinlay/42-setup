#!/usr/bin/python3
"""User-only installer for Ubuntu GNOME/X11. No sudo, no automatic screen lock."""
import argparse
import ast
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--extended-fkeys', action='store_true', help='Restore F13-F15 on a full keyboard; omit for compact keyboards')
parser.add_argument('--campus-lock', action='store_true', help='Command+L: English first, then /usr/share/42/ft_lock')
parser.add_argument('--uninstall', action='store_true', help='Restore settings saved during installation')
args = parser.parse_args()
if os.geteuid() == 0:
    sys.exit('Запускай от обычного пользователя, без sudo.')
if os.environ.get('XDG_SESSION_TYPE') != 'x11':
    sys.exit('Этот набор рассчитан на GNOME/X11. Для Wayland его применять нельзя.')
if 'GNOME' not in os.environ.get('XDG_CURRENT_DESKTOP', '').upper():
    sys.exit('Нужна графическая сессия GNOME.')

home = Path.home()
root = home / '.local/share/mac-keyboard-fix'
service = home / '.config/systemd/user/mac-keyboard-fix.service'
unit = service.name
backupfile = root / 'backup.json'
env = os.environ.copy()
env.pop('XDG_CONFIG_HOME', None)
env['GIO_EXTRA_MODULES'] = '/usr/lib/x86_64-linux-gnu/gio/modules'
media = 'org.gnome.settings-daemon.plugins.media-keys'
inputs = 'org.gnome.desktop.input-sources'
screens = 'org.gnome.shell.keybindings'
binding_path = '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/mac-keyboard-fix-lock/'
custom = media + '.custom-keybinding:' + binding_path
restore_path = '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/mac-keyboard-fix-restore/'
restore_custom = media + '.custom-keybinding:' + restore_path

def run(command, check=True):
    return subprocess.run(command, env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=check)

def get(schema, key):
    return run(['/usr/bin/gsettings', 'get', schema, key]).stdout.strip()

def put(schema, key, value):
    run(['/usr/bin/gsettings', 'set', schema, key, value])

def array(value):
    return [] if value.startswith('@as ') else ast.literal_eval(value)

def save(schema, key):
    name = schema + '|' + key
    if name not in backup['settings']:
        backup['settings'][name] = get(schema, key)
        backupfile.write_text(json.dumps(backup, indent=2, ensure_ascii=False))

if args.uninstall:
    if not backupfile.exists():
        sys.exit('Сохранённых настроек для отката нет.')
    backup = json.loads(backupfile.read_text())
    if (root / 'sources-before-lock.json').exists():
        run(['/usr/bin/python3', str(root / 'helper.py'), '--restore'])
        if (root / 'sources-before-lock.json').exists():
            sys.exit('Восстановление языков ещё выполняется; откат отменён, резервная копия сохранена.')
    run(['systemctl', '--user', 'disable', '--now', unit], check=False)
    put(custom, 'binding', "''")
    for name, value in backup['settings'].items():
        schema, key = name.split('|', 1)
        put(schema, key, value)
    for mapping in backup.get('keymap', []):
        run(['/usr/bin/xmodmap', '-e', mapping])
    if service.exists():
        service.unlink()
    run(['systemctl', '--user', 'daemon-reload'])
    shutil.rmtree(root)
    print('Откат завершён. Восстановлены сохранённые настройки.')
    sys.exit(0)

if args.campus_lock and not os.access('/usr/share/42/ft_lock', os.X_OK):
    sys.exit('ft_lock отсутствует. Убери параметр --campus-lock.')
if not (Path(__file__).parent / 'helper.py').exists():
    sys.exit('Положи helper.py рядом с install.py.')
root.mkdir(parents=True, exist_ok=True)
backup = json.loads(backupfile.read_text()) if backupfile.exists() else {'settings': {}, 'keymap': []}
shutil.copyfile(Path(__file__).parent / 'helper.py', root / 'helper.py')
shutil.copyfile(Path(__file__).parent / 'lock.py', root / 'lock.py')
for asset in ['display.py', 'auto-lock-scale.py']:
    shutil.copyfile(Path(__file__).parent / asset, root / asset)
scale_service = service.with_name('auto-lock-scale.service')
scale_service.parent.mkdir(parents=True, exist_ok=True)
scale_service.write_text('[Unit]\nDescription=Use 200 percent display scale during automatic screen locks\nAfter=graphical-session.target\nPartOf=graphical-session.target\n\n[Service]\nExecStart=/usr/bin/python3 @WATCHER@\nRestart=on-failure\nRestartSec=5\n\n[Install]\nWantedBy=graphical-session.target\n'.replace('@WATCHER@', '"' + str(root / 'auto-lock-scale.py') + '"'))
run(['systemctl', '--user', 'daemon-reload'])
run(['systemctl', '--user', 'enable', '--now', scale_service.name])



shutil.copyfile(Path(__file__).parent / 'display.py', root / 'display.py')

save(screens, 'show-screenshot-ui')
shortcuts = array(get(screens, 'show-screenshot-ui'))
for shortcut in ['Print', '<Super><Shift>s', '<Super><Shift>3']:
    if shortcut not in shortcuts:
        shortcuts.append(shortcut)
put(screens, 'show-screenshot-ui', repr(shortcuts))

save(inputs, 'xkb-options')
options = array(get(inputs, 'xkb-options'))
# GNOME owns language switching; remove competing XKB group toggles.
options = [option for option in options if not option.startswith('grp:')]
put(inputs, 'xkb-options', repr(options))

wm = 'org.gnome.desktop.wm.keybindings'
for key, binding in [('switch-input-source', '<Control>space'),
                     ('switch-input-source-backward', '<Control><Shift>space')]:
    save(wm, key)
    put(wm, key, repr([binding]))

# Release GNOME's default Command+V grab before registering paste.
save(screens, 'toggle-message-tray')
tray = array(get(screens, 'toggle-message-tray'))
tray = [binding for binding in tray if binding.lower() != '<super>v']
put(screens, 'toggle-message-tray', repr(tray))

# Remove the former global clipboard bridge; Terminal handles keys directly.
save(media, 'custom-keybindings')
paths = array(get(media, 'custom-keybindings'))
for action in ['copy', 'paste']:
    path = '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/mac-clipboard-' + action + '/'
    schema = media + '.custom-keybinding:' + path
    put(schema, 'binding', "''")
    put(schema, 'command', "''")
    put(schema, 'name', "''")
    paths = [item for item in paths if item != path]
put(media, 'custom-keybindings', repr(paths))
(root / 'clipboard.py').unlink(missing_ok=True)
(home / '.local/share/42-env/keyboard/clipboard.py').unlink(missing_ok=True)
terminal = 'org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/'
for action, letter in [('copy', 'c'), ('paste', 'v')]:
    save(terminal, action)
    put(terminal, action, repr('<Super>' + letter))


if args.extended_fkeys:
    expected_exec = 'ExecStart=/usr/bin/python3 "' + str(root / 'helper.py') + '"'
    if service.exists() and expected_exec not in service.read_text():
        sys.exit('Уже существует посторонняя служба с этим именем; остановка.')
    if not backup['keymap']:
        lines = run(['/usr/bin/xmodmap', '-pke']).stdout.splitlines()
        backup['keymap'] = [s for s in lines if re.match(r'keycode\s+(191|192|193)\s*=', s)]
        backupfile.write_text(json.dumps(backup, indent=2, ensure_ascii=False))
    run(['/usr/bin/python3', str(root / 'helper.py'), '--once'])
if args.extended_fkeys or args.campus_lock:
    service.parent.mkdir(parents=True, exist_ok=True)
    environments = '\n'.join('Environment="' + key + '=' + env[key].replace('\\', '\\\\').replace('"', '\\"') + '"' for key in ['DISPLAY', 'XAUTHORITY'] if key in env)
    exec_path = str(root / 'helper.py').replace('\\', '\\\\').replace('"', '\\"')
    watch_args = '' if args.extended_fkeys else ' --recover-only'
    service.write_text('[Unit]\nDescription=Mac keyboard recovery and optional F13-F15 mapping\nAfter=graphical-session.target\nPartOf=graphical-session.target\n\n[Service]\nExecStart=/usr/bin/python3 "' + exec_path + '"' + watch_args + '\n' + environments + '\nRestart=on-failure\nRestartSec=5\n\n[Install]\nWantedBy=graphical-session.target\n')
    run(['systemctl', '--user', 'daemon-reload'])
    run(['systemctl', '--user', 'enable', '--now', unit])

if args.campus_lock:
    for key in ['screensaver', 'custom-keybindings']:
        save(media, key)
    for key in ['name', 'command', 'binding']:
        save(custom, key)
        save(restore_custom, key)
    # Release the conflicting built-in grab before registering the custom one.
    put(media, 'screensaver', '[]')
    put(custom, 'binding', "''")
    time.sleep(0.5)
    put(custom, 'name', repr('Campus lock in English'))
    import shlex
    command = '/usr/bin/python3 ' + shlex.quote(str(root / 'helper.py')) + ' --lock'
    put(custom, 'command', repr(command))
    put(restore_custom, 'name', repr('Restore keyboard languages after campus lock'))
    put(restore_custom, 'command', repr('/usr/bin/python3 ' + shlex.quote(str(root / 'helper.py')) + ' --restore'))
    put(restore_custom, 'binding', "'<Super><Alt>r'")
    paths = array(get(media, 'custom-keybindings'))
    if binding_path not in paths:
        paths.append(binding_path)
    if restore_path not in paths:
        paths.append(restore_path)
    put(media, 'custom-keybindings', repr(paths))
    put(custom, 'binding', "'<Super>l'")

print('Готово: скриншоты Command+Shift+S / Command+Shift+3; язык Control+Space; копировать/вставить Command+C/V в GNOME Terminal.')
print('Раскладки и модель клавиатуры сохранены. F13-F15 изменяются только с --extended-fkeys.')
if args.campus_lock:
    print('Command+L временно оставляет только английский в GNOME, проверяет X11 и запускает ft_lock.')
    print('Command+Alt+R восстанавливает языки, если автоматическое восстановление не сработало.')
    print('Значок замка сверху не изменён. Разблокирование нужно проверить на этом компьютере.')
