#!/usr/bin/python3
"""Reapply this user's keyboard preferences on each GNOME/X11 login."""
import ast
import fcntl
import os
from pathlib import Path
import subprocess
import sys

home = Path.home()
env = os.environ.copy()
env.pop('XDG_CONFIG_HOME', None)
env.pop('XDG_DATA_HOME', None)
env.pop('XDG_CACHE_HOME', None)
env['GIO_EXTRA_MODULES'] = '/usr/lib/x86_64-linux-gnu/gio/modules'
env['PATH'] = '/usr/bin:/bin'
if env.get('XDG_SESSION_TYPE') != 'x11' or 'GNOME' not in env.get('XDG_CURRENT_DESKTOP', '').upper():
    print('Keyboard setup: requires GNOME/X11; skipped.')
    sys.exit(0)
state = home / '.local/state/42-env'
state.mkdir(parents=True, exist_ok=True)
guard = open(state / 'keyboard-setup.lock', 'a')
try:
    fcntl.flock(guard, fcntl.LOCK_EX | fcntl.LOCK_NB)
except BlockingIOError:
    sys.exit(0)
root = home / '.local/share/mac-keyboard-fix'
old = home / '.local/share/satechi-keyboard-fix'
for directory, helper in [(old, 'keyboard-fix.py'), (root, 'helper.py')]:
    if (directory / 'sources-before-lock.json').exists():
        # Upgrade recovery before invoking a helper left by an earlier login.
        for name in ('lock.py', 'display.py'):
            source = home / '.local/share/42-env/keyboard' / name
            target = directory / name
            temporary = target.with_name(name + '.new')
            temporary.write_bytes(source.read_bytes())
            temporary.chmod(0o700)
            temporary.replace(target)
        subprocess.run(['/usr/bin/python3', str(directory / helper), '--restore'], env=env, check=True)
        if (directory / 'sources-before-lock.json').exists():
            sys.exit('Recovery is busy; keyboard setup deferred until after unlock.')

schema = 'org.gnome.desktop.input-sources'
value = subprocess.check_output(['/usr/bin/gsettings', 'get', schema, 'sources'], env=env, text=True).strip()
sources = [] if value.startswith('@a(ss) ') else ast.literal_eval(value)
if not any(kind == 'xkb' and name.split('+')[0] in ('us', 'gb') for kind, name in sources):
    sources.insert(0, ('xkb', 'us+mac'))
if ('xkb', 'ru') not in sources:
    sources.append(('xkb', 'ru'))
subprocess.run(['/usr/bin/gsettings', 'set', schema, 'sources', repr(sources)], env=env, check=True)

# Match the exact full Satechi keyboard seen on the user's workstation.
# Compact Apple/Macintosh keyboards keep their own function-key mappings.
devices = Path('/proc/bus/input/devices').read_text()
full_satechi = any('Vendor=1c4f Product=0063' in block and 'Satechi wired keyboard"' in block for block in devices.split('\n\n'))
command = ['/usr/bin/python3', str(home / '.local/share/42-env/keyboard/install.py')]
if full_satechi:
    command.append('--extended-fkeys')
if os.access('/usr/share/42/ft_lock', os.X_OK):
    command.append('--campus-lock')
subprocess.run(command, env=env, check=True)

# Retire the earlier service and bindings only after the replacement installed.
subprocess.run(['systemctl', '--user', 'disable', '--now', 'satechi-keyboard-fix.service'], env=env, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
paths_schema = 'org.gnome.settings-daemon.plugins.media-keys'
paths = ast.literal_eval(subprocess.check_output(['/usr/bin/gsettings', 'get', paths_schema, 'custom-keybindings'], env=env, text=True).strip())
obsolete = ['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/satechi-lock/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/satechi-restore/']
for path in obsolete:
    custom = paths_schema + '.custom-keybinding:' + path
    subprocess.run(['/usr/bin/gsettings', 'set', custom, 'binding', "''"], env=env, check=True)
paths = [path for path in paths if path not in obsolete]
subprocess.run(['/usr/bin/gsettings', 'set', paths_schema, 'custom-keybindings', repr(paths)], env=env, check=True)
# Re-register after the old Command+L grab was released.
if '--campus-lock' in command:
    import time
    for suffix, binding in [('lock', '<Super>l'), ('restore', '<Super><Alt>r')]:
        custom = paths_schema + '.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/mac-keyboard-fix-' + suffix + '/'
        subprocess.run(['/usr/bin/gsettings', 'set', custom, 'binding', "''"], env=env, check=True)
        time.sleep(0.5)
        subprocess.run(['/usr/bin/gsettings', 'set', custom, 'binding', repr(binding)], env=env, check=True)
if full_satechi or '--campus-lock' in command:
    subprocess.run(['systemctl', '--user', 'restart', 'mac-keyboard-fix.service'], env=env, check=True)
print('Keyboard setup applied: ' + ('full Satechi, F13-F15 enabled' if full_satechi else 'compact/other keyboard, F13-F15 unchanged'))
