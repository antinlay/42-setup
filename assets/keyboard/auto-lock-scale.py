#!/usr/bin/python3
"""Temporarily use integer display scaling for automatic screen locks."""
import json
import os
from pathlib import Path
import time
from gi.repository import Gio, GLib
from display import snapshot_display, apply_display

root = Path(__file__).resolve().parent
pending = root / 'auto-lock-display.json'
bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)

def locked():
    # The campus daemon stays alive when unlocked; its children are the locker.
    for p in Path('/proc').glob('[0-9]*/cmdline'):
        try:
            if p.stat().st_uid != os.getuid():
                continue
            argv = p.read_bytes().split(b'\0')
            if argv[0].startswith(b'[ft_ld]'):
                if (p.parent / 'task' / p.parent.name / 'children').read_text().strip():
                    return True
            elif argv[0] == b'/usr/share/42/ft_lock' and b'-d' not in argv:
                return True
        except (OSError, IndexError):
            pass
    try:
        return bus.call_sync('org.gnome.ScreenSaver', '/org/gnome/ScreenSaver',
            'org.gnome.ScreenSaver', 'GetActive', None, None,
            Gio.DBusCallFlags.NONE, 2000, None).unpack()[0]
    except GLib.Error as error:
        # Campus sessions can disable GNOME ScreenShield entirely.
        if 'ServiceUnknown' in str(error) or 'UnknownMethod' in str(error):
            return False
        raise

while True:
    try:
        active = locked()
        if active and not pending.exists():
            saved = snapshot_display()
            if saved:
                temporary = pending.with_suffix('.tmp')
                temporary.write_text(json.dumps(saved))
                temporary.chmod(0o600)
                temporary.replace(pending)
                apply_display(saved, 2.0)
                print('Lock detected: scale 200%', flush=True)
        elif not active and pending.exists():
            saved = json.loads(pending.read_text())
            try:
                apply_display(saved)
            except RuntimeError as error:
                if 'topology changed' not in str(error):
                    raise
                pending.replace(root / 'auto-lock-display-old-monitor.json')
                print(str(error), flush=True)
            else:
                pending.unlink()
                print('Unlocked: previous scale restored', flush=True)
    except Exception as error:
        print('Scale watcher: ' + str(error), flush=True)
    time.sleep(1)
