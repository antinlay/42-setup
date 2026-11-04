"""Install the bundled editor settings; safe to rerun at each GNOME login."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
from datetime import datetime


def install(home, assets):
    state = home / '.local/state/42-env/editor'
    state.mkdir(parents=True, exist_ok=True)
    backups = state / 'backups'
    for source, relative in [('vimrc', '.vimrc'), ('xcode_dark.vim', '.vim/colors/xcode_dark.vim')]:
        target = home / relative
        data = assets[source].encode()
        if target.is_file() and target.read_bytes() == data:
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        if target.exists() or target.is_symlink():
            backups.mkdir(parents=True, exist_ok=True)
            backup = backups / (source + '-' + datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
            shutil.copy2(target, backup)
        fd, temporary = tempfile.mkstemp(prefix='.42-editor-', dir=target.parent)
        try:
            with os.fdopen(fd, 'wb') as output:
                output.write(data)
            os.replace(temporary, target)
        finally:
            if os.path.exists(temporary):
                os.unlink(temporary)
    print('Vim: installed Xcode-style colors, terminal background and 4-column C/C++ tabs.')
    return state


def terminal_profile(state, profile):
    # App launchers can override XDG roots: target the actual desktop profile.
    env = os.environ.copy()
    env['PATH'] = '/usr/bin:/bin'
    for key, suffix in [('XDG_CONFIG_HOME', '/.config'), ('XDG_DATA_HOME', '/.local/share'), ('XDG_CACHE_HOME', '/.cache')]:
        env[key] = str(Path.home()) + suffix
    if not (env.get('DBUS_SESSION_BUS_ADDRESS') and shutil.which('gsettings', path=env['PATH'])):
        print('Terminal profile deferred: no desktop D-Bus session.')
        return

    def run(*args):
        return subprocess.check_output(args, env=env, text=True, stderr=subprocess.PIPE).strip()

    try:
        import ast
        registry = 'org.gnome.Terminal.ProfilesList'
        profiles_before = run('gsettings', 'get', registry, 'list')
        profiles = ast.literal_eval(profiles_before.removeprefix('@as '))
        uuid = profile['uuid']
        schema = 'org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:' + uuid + '/'
        supported = set(run('gsettings', 'list-keys', schema).splitlines())
        # Save the entire effective target profile and registry before any write.
        backup = state / 'terminal-before.json'
        if not backup.exists():
            previous = {key: run('gsettings', 'get', schema, key) for key in sorted(supported)}
            backup.write_text(json.dumps({
                'uuid': uuid, 'profiles': profiles_before,
                'default': run('gsettings', 'get', registry, 'default'),
                'settings': previous,
            }, indent=2) + '\n')
        failures = []
        for key, value in profile['settings'].items():
            if key not in supported:
                print('Terminal: unsupported setting skipped:', key)
                continue
            if run('gsettings', 'get', schema, key) == value:
                continue
            if run('gsettings', 'writable', schema, key) != 'true':
                print('Terminal: locked setting skipped:', key)
                continue
            try:
                run('gsettings', 'set', schema, key, value)
            except subprocess.CalledProcessError:
                failures.append(key)
        if uuid not in profiles:
            profiles.append(uuid)
            run('gsettings', 'set', registry, 'list', repr(profiles))
        if run('gsettings', 'get', registry, 'default') != repr(uuid):
            run('gsettings', 'set', registry, 'default', repr(uuid))
        print('GNOME Terminal: lebowski profile selected; Liberation Mono 12.')
        if failures:
            print('Terminal settings could not be applied:', ', '.join(failures))
    except (subprocess.CalledProcessError, ValueError, OSError) as error:
        print('GNOME Terminal profile skipped:', error)


def main(assets):
    state = install(Path.home(), assets)
    terminal_profile(state, json.loads(assets['terminal-profile.json']))
