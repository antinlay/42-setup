"""Temporary integer scaling for the campus locker on a single iMac display."""
from gi.repository import Gio, GLib


def call(method, args=None):
    bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    return bus.call_sync('org.gnome.Mutter.DisplayConfig',
        '/org/gnome/Mutter/DisplayConfig', 'org.gnome.Mutter.DisplayConfig',
        method, args, None, Gio.DBusCallFlags.NONE, 5000, None).unpack()


def snapshot_display():
    state = call('GetCurrentState')
    if len(state[1]) != 1 or len(state[2]) != 1:
        return None
    monitor, logical = state[1][0], state[2][0]
    if monitor[0][1:3] != ('APP', 'iMac') or len(logical[5]) != 1:
        return None
    scale = logical[2]
    if abs(scale - round(scale)) < .001:
        return None
    mode = next(m for m in monitor[1] if m[6].get('is-current'))
    if 2.0 not in mode[5]:
        raise RuntimeError('200% scaling is not supported on this monitor')
    return {'spec': list(monitor[0]), 'mode': mode[0], 'scale': scale,
        'x': logical[0], 'y': logical[1], 'transform': logical[3],
        'primary': logical[4], 'layout_mode': state[3]['layout-mode'],
        'underscanning': monitor[2].get('is-underscanning', False)}


def apply_display(saved, scale=None):
    if saved is None:
        return
    state = call('GetCurrentState')
    if len(state[1]) != 1 or list(state[1][0][0]) != saved['spec']:
        raise RuntimeError('Display topology changed; saved display settings retained for recovery')
    requested = saved['scale'] if scale is None else scale
    args = GLib.Variant('(uua(iiduba(ssa{sv}))a{sv})',
        (state[0], 1, [(saved['x'], saved['y'], requested,
          saved['transform'], saved['primary'], [(saved['spec'][0], saved['mode'],
          {'underscanning': GLib.Variant('b', saved['underscanning'])})])],
          {'layout-mode': GLib.Variant('u', saved['layout_mode'])}))
    call('ApplyMonitorsConfig', args)
    current = call('GetCurrentState')
    if len(current[2]) != 1 or abs(current[2][0][2] - requested) > .001:
        raise RuntimeError('Requested display scaling was not applied')
