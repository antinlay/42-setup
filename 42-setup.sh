#!/usr/bin/env bash
# Ubuntu x86_64, user-owned /goinfre environment. Never invokes sudo.
set -Eeuo pipefail
umask 077
ACCOUNT="$(id -un)"
ROOT="/goinfre/$ACCOUNT"
BREW="$ROOT/b"
BIN="$HOME/.local/bin"
STATE="$HOME/.local/state/42-env"
MODE="${1:-}"

# BEGIN 42 DESKTOP AUTOSTART
/usr/bin/python3 <<'PY_42_DESKTOP'
import base64
from pathlib import Path
home=Path.home()
p=home/'.local/bin/42-desktop'
p.parent.mkdir(parents=True,exist_ok=True)
p.write_bytes(base64.b64decode('IyEvdXNyL2Jpbi9weXRob24zCiIiIlJlc3RvcmUgdGhlIHNhdmVkIDQyIGRlc2t0b3AgaW4gYW4gWDExIGxvZ2luIHNlc3Npb24uIiIiCmltcG9ydCBjdHlwZXMgYXMgQwppbXBvcnQganNvbiwgb3MsIHJlLCBzdWJwcm9jZXNzLCB0aW1lLCBmY250bApmcm9tIHBhdGhsaWIgaW1wb3J0IFBhdGgKaG9tZT1QYXRoLmhvbWUoKQpzdGF0ZT1ob21lLycubG9jYWwvc3RhdGUvNDItZW52Jzsgc3RhdGUubWtkaXIocGFyZW50cz1UcnVlLGV4aXN0X29rPVRydWUpCmxvY2s9b3BlbihzdGF0ZS8nZGVza3RvcC5sb2NrJywndycpCnRyeTogZmNudGwuZmxvY2sobG9jayxmY250bC5MT0NLX0VYfGZjbnRsLkxPQ0tfTkIpCmV4Y2VwdCBCbG9ja2luZ0lPRXJyb3I6IHJhaXNlIFN5c3RlbUV4aXQoMCkKbGF5b3V0PWpzb24ubG9hZHMoKGhvbWUvJy5sb2NhbC9zaGFyZS80Mi1lbnYvZGVza3RvcC1sYXlvdXQuanNvbicpLnJlYWRfdGV4dCgpKQpkZWYgb3V0cHV0KCphcmdzKToKICAgIHJldHVybiBzdWJwcm9jZXNzLmNoZWNrX291dHB1dChhcmdzLHRleHQ9VHJ1ZSxzdGRlcnI9c3VicHJvY2Vzcy5ERVZOVUxMKQpkZWYgd2luZG93cygpOgogICAgcmVzdWx0PXt9CiAgICBmb3Igd2lkIGluIHJlLmZpbmRhbGwocicweFswLTlhLWZdKycsb3V0cHV0KCd4cHJvcCcsJy1yb290JywnX05FVF9DTElFTlRfTElTVCcpKToKICAgICAgICB0cnk6IHJlc3VsdFtpbnQod2lkLDE2KV09b3V0cHV0KCd4cHJvcCcsJy1pZCcsd2lkLCdXTV9DTEFTUycpCiAgICAgICAgZXhjZXB0IHN1YnByb2Nlc3MuQ2FsbGVkUHJvY2Vzc0Vycm9yOiBwYXNzCiAgICByZXR1cm4gcmVzdWx0CmlmIG9zLmVudmlyb24uZ2V0KCdYREdfU0VTU0lPTl9UWVBFJyk9PSd3YXlsYW5kJzogcmFpc2UgU3lzdGVtRXhpdCgnNDIgZGVza3RvcCByZXF1aXJlcyBYMTEnKQp4PUMuQ0RMTCgnbGliWDExLnNvLjYnKQp4LlhPcGVuRGlzcGxheS5hcmd0eXBlcz1bQy5jX2NoYXJfcF07IHguWE9wZW5EaXNwbGF5LnJlc3R5cGU9Qy5jX3ZvaWRfcAp4LlhEZWZhdWx0Um9vdFdpbmRvdy5hcmd0eXBlcz1bQy5jX3ZvaWRfcF07IHguWERlZmF1bHRSb290V2luZG93LnJlc3R5cGU9Qy5jX3Vsb25nCnguWEludGVybkF0b20uYXJndHlwZXM9W0MuY192b2lkX3AsQy5jX2NoYXJfcCxDLmNfaW50XTsgeC5YSW50ZXJuQXRvbS5yZXN0eXBlPUMuY191bG9uZwpjbGFzcyBEYXRhKEMuVW5pb24pOiBfZmllbGRzXz1bKCdsJyxDLmNfbG9uZyo1KSwoJ2InLEMuY19jaGFyKjIwKV0KY2xhc3MgRXZlbnQoQy5TdHJ1Y3R1cmUpOgogICAgX2ZpZWxkc189WygndHlwZScsQy5jX2ludCksKCdzZXJpYWwnLEMuY191bG9uZyksKCdzZW5kX2V2ZW50JyxDLmNfaW50KSwoJ2Rpc3BsYXknLEMuY192b2lkX3ApLCgnd2luZG93JyxDLmNfdWxvbmcpLCgnbWVzc2FnZV90eXBlJyxDLmNfdWxvbmcpLCgnZm9ybWF0JyxDLmNfaW50KSwoJ2RhdGEnLERhdGEpXQpjbGFzcyBYRXZlbnQoQy5Vbmlvbik6IF9maWVsZHNfPVsoJ2NsaWVudCcsRXZlbnQpLCgncGFkZGluZycsQy5jX2xvbmcqMjQpXQp4LlhTZW5kRXZlbnQuYXJndHlwZXM9W0MuY192b2lkX3AsQy5jX3Vsb25nLEMuY19pbnQsQy5jX2xvbmcsQy5QT0lOVEVSKFhFdmVudCldCnguWEZsdXNoLmFyZ3R5cGVzPVtDLmNfdm9pZF9wXQpkaXNwbGF5PXguWE9wZW5EaXNwbGF5KE5vbmUpCmlmIG5vdCBkaXNwbGF5OiByYWlzZSBTeXN0ZW1FeGl0KCdObyBYIGRpc3BsYXknKQpyb290PXguWERlZmF1bHRSb290V2luZG93KGRpc3BsYXkpCmRlZiBhdG9tKHMpOiByZXR1cm4geC5YSW50ZXJuQXRvbShkaXNwbGF5LHMuZW5jb2RlKCksMCkKZGVmIHNlbmQodyxuYW1lLHZhbHVlcyk6CiAgICBldmVudD1YRXZlbnQoKTsgZXZlbnQuY2xpZW50LnR5cGU9MzM7IGV2ZW50LmNsaWVudC5kaXNwbGF5PWRpc3BsYXkKICAgIGV2ZW50LmNsaWVudC53aW5kb3c9dzsgZXZlbnQuY2xpZW50Lm1lc3NhZ2VfdHlwZT1hdG9tKG5hbWUpOyBldmVudC5jbGllbnQuZm9ybWF0PTMyCiAgICBmb3IgaSx2IGluIGVudW1lcmF0ZSh2YWx1ZXMpOiBldmVudC5jbGllbnQuZGF0YS5sW2ldPXYKICAgIHguWFNlbmRFdmVudChkaXNwbGF5LHJvb3QsMCwoMTw8MjApfCgxPDwxOSksQy5ieXJlZihldmVudCkpOyB4LlhGbHVzaChkaXNwbGF5KQpkZWYgcGxhY2UodyxnKToKICAgIHNlbmQodywnX05FVF9XTV9TVEFURScsWzAsYXRvbSgnX05FVF9XTV9TVEFURV9NQVhJTUlaRURfVkVSVCcpLGF0b20oJ19ORVRfV01fU1RBVEVfTUFYSU1JWkVEX0hPUlonKSwxLDBdKQogICAgc2VuZCh3LCdfTkVUX01PVkVSRVNJWkVfV0lORE9XJyxbMTB8KDE1PDw4KXwoMTw8MTIpLCpnXSkKIyBMZXQgZGlzcGxheSBzY2FsaW5nIGFuZCB0aGUgZGVza3RvcCBzdGFydHVwIGZpbmlzaCBmaXJzdC4KdGltZS5zbGVlcCgxMCkKZXhpc3Rpbmc9d2luZG93cygpOyBzZWxlY3RlZD17fQpmb3IgbmFtZSxpdGVtIGluIGxheW91dC5pdGVtcygpOgogICAgbWF0Y2hlcz1bdyBmb3IgdyxjIGluIGV4aXN0aW5nLml0ZW1zKCkgaWYgaXRlbVsnbWF0Y2gnXS5sb3dlcigpIGluIGMubG93ZXIoKV0KICAgIGlmIG1hdGNoZXM6CiAgICAgICAgc2VsZWN0ZWRbbmFtZV09bWF0Y2hlc1swXQogICAgICAgIGNvbnRpbnVlCiAgICBpZiBuYW1lPT0ndGVybWluYWwnOgogICAgICAgIHN1YnByb2Nlc3MuUG9wZW4oWycvdXNyL2Jpbi9nbm9tZS10ZXJtaW5hbCcsJy0td2luZG93JywnLS13b3JraW5nLWRpcmVjdG9yeT0nK3N0cihob21lLydEZXZlbG9wZXInKV0sc3Rkb3V0PXN1YnByb2Nlc3MuREVWTlVMTCxzdGRlcnI9c3VicHJvY2Vzcy5ERVZOVUxMKQogICAgZWxzZToKICAgICAgICBzdWJwcm9jZXNzLlBvcGVuKFtzdHIoaG9tZS8nLmxvY2FsL2JpbicvKCc0Mi0nK25hbWUpKV0sc3Rkb3V0PXN1YnByb2Nlc3MuREVWTlVMTCxzdGRlcnI9c3VicHJvY2Vzcy5ERVZOVUxMKQojIEFsbG93IHNsb3cgRWxlY3Ryb24vYnJvd3NlciBzdGFydHVwOyBwbGFjZSBlYWNoIHdpbmRvdyByZXBlYXRlZGx5IHdoaWxlIGl0IHNldHRsZXMuCmNvdW50cz17bmFtZTowIGZvciBuYW1lIGluIGxheW91dH0KZm9yIGF0dGVtcHQgaW4gcmFuZ2UoMTIwKToKICAgIGN1cnJlbnQ9d2luZG93cygpCiAgICBmb3IgbmFtZSxpdGVtIGluIGxheW91dC5pdGVtcygpOgogICAgICAgIGlmIG5hbWUgbm90IGluIHNlbGVjdGVkOgogICAgICAgICAgICBtYXRjaGVzPVt3IGZvciB3LGMgaW4gY3VycmVudC5pdGVtcygpIGlmIGl0ZW1bJ21hdGNoJ10ubG93ZXIoKSBpbiBjLmxvd2VyKCldCiAgICAgICAgICAgIGlmIG1hdGNoZXM6IHNlbGVjdGVkW25hbWVdPW1hdGNoZXNbMF0KICAgICAgICBpZiBuYW1lIGluIHNlbGVjdGVkIGFuZCBjb3VudHNbbmFtZV08ODoKICAgICAgICAgICAgcGxhY2Uoc2VsZWN0ZWRbbmFtZV0saXRlbVsnZ2VvbWV0cnknXSk7IGNvdW50c1tuYW1lXSs9MQogICAgaWYgYWxsKHY+PTggZm9yIHYgaW4gY291bnRzLnZhbHVlcygpKTogYnJlYWsKICAgIHRpbWUuc2xlZXAoMSkKbWlzc2luZz1bbmFtZSBmb3IgbmFtZSxjb3VudCBpbiBjb3VudHMuaXRlbXMoKSBpZiBub3QgY291bnRdCihzdGF0ZS8nZGVza3RvcC1zdGF0dXMubG9nJykud3JpdGVfdGV4dCh0aW1lLnN0cmZ0aW1lKCclWS0lbS0lZCAlSDolTTolUycpKycgbWlzc2luZzogJytyZXByKG1pc3NpbmcpKydcbicpCg=='))
p.chmod(0o700)
p=home/'.local/share/42-env/desktop-layout.json'
p.parent.mkdir(parents=True,exist_ok=True)
p.write_bytes(base64.b64decode('ewogICJncHQiOiB7CiAgICAibWF0Y2giOiAiQ2hhdGdwdCIsCiAgICAiZ2VvbWV0cnkiOiBbCiAgICAgIDAsCiAgICAgIDY0LAogICAgICAxODQyLAogICAgICAyODE2CiAgICBdCiAgfSwKICAiY2hyb21lIjogewogICAgIm1hdGNoIjogIjQyLWNocm9tZSIsCiAgICAiZ2VvbWV0cnkiOiBbCiAgICAgIDMzMTUsCiAgICAgIDI2LAogICAgICAxODQ4LAogICAgICAyODk3CiAgICBdCiAgfSwKICAiZGlzY29yZCI6IHsKICAgICJtYXRjaCI6ICJkaXNjb3JkIiwKICAgICJnZW9tZXRyeSI6IFsKICAgICAgMTI4MCwKICAgICAgNzUyLAogICAgICAyNTYwLAogICAgICAxNDQwCiAgICBdCiAgfSwKICAidGVybWluYWwiOiB7CiAgICAibWF0Y2giOiAiR25vbWUtdGVybWluYWwiLAogICAgImdlb21ldHJ5IjogWwogICAgICAxNjYwLAogICAgICAxOCwKICAgICAgMTg2NCwKICAgICAgMjE4MgogICAgXQogIH0KfQ=='))
p=home/'.config/autostart/42-desktop.desktop'
p.parent.mkdir(parents=True,exist_ok=True)
p.write_bytes(base64.b64decode('W0Rlc2t0b3AgRW50cnldClR5cGU9QXBwbGljYXRpb24KTmFtZT00MiBkZXNrdG9wIGxheW91dApFeGVjPSIvaG9tZS9hbGlha2hldi8ubG9jYWwvYmluLzQyLWRlc2t0b3AiClRlcm1pbmFsPWZhbHNlClgtR05PTUUtQXV0b3N0YXJ0LWVuYWJsZWQ9dHJ1ZQo='))
PY_42_DESKTOP
# END 42 DESKTOP AUTOSTART

# This script must use system utilities, even when launched from ChatGPT/Homebrew.
export PATH="/usr/bin:/bin:$PATH"
[[ "$EUID" != 0 ]] || { echo "Запускай без sudo."; exit 1; }

install_keyboard_assets() {
    /usr/bin/python3 - "$HOME/.local/share/42-env" <<'PY_ASSETS'
import base64, io, os, sys, zipfile
from pathlib import Path
root = Path(sys.argv[1])
root.mkdir(parents=True, exist_ok=True)
payload = "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"
with zipfile.ZipFile(io.BytesIO(base64.b64decode(payload))) as bundle:
    for name in ['42-keyboard.py', 'keyboard/helper.py', 'keyboard/install.py', 'keyboard/lock.py', 'keyboard/display.py', 'keyboard/auto-lock-scale.py']:
        target = root / name
        target.parent.mkdir(parents=True, exist_ok=True)
        temporary = target.with_name(target.name + '.new')
        temporary.write_bytes(bundle.read(name))
        temporary.chmod(0o700)
        temporary.replace(target)
PY_ASSETS
    mkdir -p "$BIN"
    cat > "$BIN/42-keyboard" <<'KEYBOARD_LAUNCH'
#!/bin/bash
exec /usr/bin/python3 "$HOME/.local/share/42-env/42-keyboard.py" "$@"
KEYBOARD_LAUNCH
    chmod 700 "$BIN/42-keyboard"
}


apply_scale() {
    /usr/bin/python3 <<'PY_SCALE'
import time
from gi.repository import Gio, GLib
bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
def call(name, args=None):
    return bus.call_sync('org.gnome.Mutter.DisplayConfig',
        '/org/gnome/Mutter/DisplayConfig', 'org.gnome.Mutter.DisplayConfig',
        name, args, None, Gio.DBusCallFlags.NONE, 5000, None).unpack()
for attempt in range(15):
    try:
        state = call('GetCurrentState')
        if len(state[1]) != 1 or len(state[2]) != 1:
            raise RuntimeError('Expected one monitor; configuration left unchanged')
        monitor, logical = state[1][0], state[2][0]
        mode = next(m for m in monitor[1] if m[6].get('is-current'))
        if not any(abs(s - 1.5) < .001 for s in mode[5]):
            raise RuntimeError('Current monitor mode does not support 150%')
        if abs(logical[2] - 1.5) > .001:
            call('ApplyMonitorsConfig', GLib.Variant('(uua(iiduba(ssa{sv}))a{sv})',
                (state[0], 1, [(logical[0], logical[1], 1.5, logical[3], logical[4],
                [(monitor[0][0], mode[0], {'underscanning': GLib.Variant('b',
                monitor[2].get('is-underscanning', False))})])],
                {'layout-mode': GLib.Variant('u', state[3]['layout-mode'])})))
        current = call('GetCurrentState')
        if abs(current[2][0][2] - 1.5) > .001:
            raise RuntimeError('150% verification failed')
        # Save this monitor's configuration without triggering GNOME's confirmation timeout.
        from pathlib import Path
        import xml.etree.ElementTree as ET
        import shutil
        config = Path.home() / '.config/monitors.xml'
        if config.exists():
            tree = ET.parse(config)
            shutil.copy2(config, config.with_name('monitors.xml.before-42-scale'))
        else:
            tree = ET.ElementTree(ET.Element('monitors', version='2'))
        root = tree.getroot()
        spec = monitor[0]
        for previous in list(root):
            specs = previous.findall('./logicalmonitor/monitor/monitorspec')
            if len(specs) == 1 and tuple(specs[0].findtext(k) for k in
                    ('connector', 'vendor', 'product', 'serial')) == tuple(spec):
                root.remove(previous)
        configuration = ET.SubElement(root, 'configuration')
        item = ET.SubElement(configuration, 'logicalmonitor')
        for key, value in [('x', logical[0]), ('y', logical[1]), ('scale', '1.5'),
                           ('primary', 'yes' if logical[4] else 'no')]:
            ET.SubElement(item, key).text = str(value)
        transform = ET.SubElement(item, 'transform')
        ET.SubElement(transform, 'rotation').text = ('normal', 'left', 'upside_down', 'right')[logical[3] % 4]
        ET.SubElement(transform, 'flipped').text = 'yes' if logical[3] >= 4 else 'no'
        physical = ET.SubElement(item, 'monitor')
        identity = ET.SubElement(physical, 'monitorspec')
        for key, value in zip(('connector', 'vendor', 'product', 'serial'), spec):
            ET.SubElement(identity, key).text = value
        saved_mode = ET.SubElement(physical, 'mode')
        for key, value in [('width', mode[1]), ('height', mode[2]), ('rate', mode[3])]:
            ET.SubElement(saved_mode, key).text = str(value)
        if monitor[2].get('is-underscanning', False):
            ET.SubElement(physical, 'underscanning').text = 'yes'
        temporary = config.with_name('monitors.xml.42-new')
        tree.write(temporary, encoding='unicode')
        temporary.replace(config)
        print('Display scale verified and saved: 150%', flush=True)
        break
    except Exception as error:
        if attempt == 14:
            raise SystemExit(str(error))
        time.sleep(2)
PY_SCALE
}

enable() {
    mkdir -p "$BIN" "$STATE" "$HOME/.config/autostart"
    install_keyboard_assets
    local target="$BIN/42-setup" source_path
    source_path="$(readlink -f "${BASH_SOURCE[0]}")"
    if [[ "$source_path" != "$target" ]]; then
        if [[ -f "$target" ]] && ! cmp -s "$source_path" "$target"; then
            mkdir -p "$STATE/backups"
            cp -p "$target" "$STATE/backups/42-setup-$(date +%Y%m%d-%H%M%S)"
        fi
        install -m 700 "$source_path" "$target"
    fi
    # Desktop Entry quoting handles spaces in HOME.
    local escaped="${target//\\/\\\\}"
    escaped="${escaped//\"/\\\"}"
    escaped="${escaped//\$/\\\$}"
    escaped="${escaped//\`/\\\`}"
    cat > "$HOME/.config/autostart/42-env.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=42 environment setup
Exec="$escaped" --background
Terminal=false
EOF
    cat > "$HOME/.config/autostart/42-keyboard.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=42 keyboard setup
Exec="$escaped" --keyboard
Terminal=false
X-GNOME-Autostart-enabled=true
EOF
    cat > "$HOME/.config/autostart/42-display.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=42 display scale 150%
Exec="$escaped" --scale
Terminal=false
X-GNOME-Autostart-enabled=true
EOF
    cat > "$BIN/42-paths.zsh" <<'EOF'
export PATH="$HOME/.local/bin:/goinfre/$(id -un)/b/bin:/goinfre/$(id -un)/b/sbin:$PATH"
EOF
    touch "$HOME/.zshrc"
    if ! grep -Fqx 'source "$HOME/.local/bin/42-paths.zsh"' "$HOME/.zshrc"; then
        printf '\nsource "$HOME/.local/bin/42-paths.zsh"\n' >> "$HOME/.zshrc"
    fi
    echo "Автозапуск включён. Установка: bash \"$target\""
}

setup_portable_tools() (
    set -Eeuo pipefail
    mkdir -p "$ROOT/cache/desktop" "$ROOT/cache/brew" "$ROOT/tmp" "$BIN"
    exec 8>"$ROOT/tmp/portable-tools.lock"
    flock 8
    if [[ -L "$HOME/.cache" && ! -e "$HOME/.cache" ]]; then
        mkdir -p -- "$(readlink -m "$HOME/.cache")"
    fi
    if [[ ! -f "$HOME/mini-moulinette/mini-moul.sh" ]]; then
        if [[ -e "$HOME/mini-moulinette" ]]; then
            echo 'mini-moulinette: existing directory preserved; missing mini-moul.sh' >&2
            exit 1
        fi
        git clone https://github.com/k11q/mini-moulinette.git "$HOME/mini-moulinette"
    fi
    cat > "$BIN/mini" <<'MINI_LAUNCH'
#!/bin/bash
if [[ ! -f "$HOME/mini-moulinette/mini-moul.sh" ]]; then
    "$HOME/.local/bin/42-setup" --tools || exit $?
fi
exec /bin/bash "$HOME/mini-moulinette/mini-moul.sh" "$@"
MINI_LAUNCH
    cat > "$BIN/brew" <<'BREW_LAUNCH'
#!/bin/bash
brew_path="/goinfre/$(id -un)/b/bin/brew"
if [[ ! -x "$brew_path" ]]; then
    "$HOME/.local/bin/42-setup" --tools || exit $?
fi
exec "$brew_path" "$@"
BREW_LAUNCH
    chmod 700 "$BIN/mini" "$BIN/brew"
    if [[ ! -x "$BREW/bin/brew" ]]; then
        local stage
        stage="$(mktemp -d "$ROOT/tmp/brew-install.XXXXXX")"
        trap 'rm -rf -- "$stage"' EXIT
        curl --fail --location --retry 3 --proto '=https' --proto-redir '=https' \
            https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$stage/install.sh"
        NONINTERACTIVE=1 HOMEBREW_NO_SUDO=1 HOMEBREW_CACHE="$ROOT/cache/brew" \
            /bin/bash "$stage/install.sh" --path "$BREW"
    fi
)

case "${1:-}" in
    --tools) setup_portable_tools; exit 0 ;;
    --scale)
        mkdir -p "$STATE"
        exec >>"$STATE/display.log" 2>&1
        echo "=== $(date -Is) $(hostname) display ==="
        apply_scale; exit 0 ;;
    --enable) enable; exit 0 ;;
    --disable)
        rm -f "$HOME/.config/autostart/42-display.desktop" "$HOME/.config/autostart/42-env.desktop" "$HOME/.config/autostart/42-keyboard.desktop"
        systemctl --user disable --now mac-keyboard-fix.service auto-lock-scale.service 2>/dev/null || true
        echo 'Автозапуск выключен; текущие сочетания клавиш сохранены.'; exit 0 ;;
    --keyboard)
        install_keyboard_assets
        mkdir -p "$STATE"
        exec >>"$STATE/keyboard.log" 2>&1
        echo "=== $(date -Is) $(hostname) keyboard ==="
        exec "$BIN/42-keyboard" ;;
    ''|--background|--force-update|--chatgpt-only) ;;
    *) echo 'Usage: 42-setup [--tools|--scale|--enable|--disable|--force-update|--background|--keyboard|--chatgpt-only]'; exit 2 ;;
esac

mkdir -p "$STATE" "$BIN"
exec 9>"$STATE/setup.lock"
flock -n 9 || { echo 'Установщик уже работает.'; exit 0; }
if [[ -f "$STATE/setup.log" ]] && (( $(stat -c %s "$STATE/setup.log") > 2097152 )); then
    mv -f "$STATE/setup.log" "$STATE/setup.log.old"
fi
if [[ "${1:-}" == --background ]]; then
    exec >>"$STATE/setup.log" 2>&1
else
    exec > >(tee -a "$STATE/setup.log") 2>&1
fi
echo "=== $(date -Is) $(hostname) ==="
trap 'echo "Ошибка, строка $LINENO. Лог: $STATE/setup.log"' ERR
[[ "$(uname -m)" == x86_64 ]] || { echo 'Нужен x86_64 Linux.'; exit 1; }
[[ -d /goinfre && -w /goinfre ]] || { echo '/goinfre недоступен.'; exit 1; }
mkdir -p "$ROOT"
[[ -O "$ROOT" && ! -L "$ROOT" ]] || { echo 'Неверный владелец или symlink у каталога /goinfre.'; exit 1; }
chmod 700 "$ROOT"
mkdir -p "$ROOT"/{apps,cache,tmp,models,venvs}
export TMPDIR="$ROOT/tmp"
export HOMEBREW_CACHE="$ROOT/cache/brew"
export PIP_CACHE_DIR="$ROOT/cache/pip"
export HF_HOME="$ROOT/cache/huggingface"
export HOMEBREW_NO_SUDO=1 HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ANALYTICS=1
WORK="$(mktemp -d "$ROOT/tmp/setup.XXXXXX")"
trap 'rm -rf -- "$WORK"' EXIT
download() {
    curl --fail --location --retry 3 --connect-timeout 20 --max-time 1800 \
        --proto '=https' --proto-redir '=https' "$1" -o "$2"
}

setup_portable_tools || { echo "Portable tools setup failed; retry 42-setup --tools."; }

# A system Chrome/Discord process must not block our first installation.
own_app_running() {
    local name="$1" pattern="$2" pid path
    while read -r pid; do
        path="$(readlink -f "/proc/$pid/exe" 2>/dev/null || true)"
        case "$path" in
            "$ROOT/apps/$name-"*|"$ROOT/runtime-config/discord/"*|"$ROOT/chatgpt-desktop/"*) return 0 ;;
        esac
    done < <(pgrep -u "$(id -u)" -x "$pattern" || true)
    return 1
}

# Some Discord updater releases return app-VERSION without making a root link.
prepare_discord_runtime() {
    local bootstrap="$1" runtime="$ROOT/runtime-config/discord"
    local folder candidate='' output line
    mkdir -p "$runtime"
    [[ ! -x "$runtime/Discord" ]] || return 0
    # Recover an installation that completed before a previous setup failed.
    while IFS= read -r folder; do
        [[ ! -x "$folder/Discord" ]] || candidate="$folder"
    done < <(printf '%s\n' "$runtime"/app-* | sort -V)
    if [[ -z "$candidate" ]]; then
        output="$(timeout 1800 "$bootstrap" --no-zenity "$runtime" stable https://updates.discord.com/)"
        printf '%s\n' "$output"
        while IFS= read -r line; do
            if [[ "$line" =~ ^app-[0-9]+\.[0-9]+\.[0-9]+$ && -x "$runtime/$line/Discord" ]]; then
                candidate="$runtime/$line"
            fi
        done <<< "$output"
        if [[ -z "$candidate" ]]; then
            while IFS= read -r folder; do
                [[ ! -x "$folder/Discord" ]] || candidate="$folder"
            done < <(printf '%s\n' "$runtime"/app-* | sort -V)
        fi
    fi
    [[ -n "$candidate" ]] || { echo 'Discord updater: не найден app-*/Discord.'; return 1; }
    ln -s "$(basename "$candidate")/Discord" "$WORK/discord-runtime-link"
    mv -Tf "$WORK/discord-runtime-link" "$runtime/Discord"
    [[ -x "$runtime/Discord" ]]
}

# App versions are immutable directories. Updates switch a symlink atomically.
# We retain previous versions: never delete files from a running process.
update_app() (
    set -Eeuo pipefail
    trap - EXIT
    local name="$1" url="$2" process="$3" executable="$4"
    local current="$ROOT/apps/$name" stamp="$ROOT/apps/.$name-checked"
    local now last=0 archive="$WORK/$name.download" hash version stage previous=''
    now="$(date +%s)"
    [[ ! -f "$stamp" ]] || read -r last < "$stamp"
    [[ "$last" =~ ^[0-9]+$ ]] || last=0
    if [[ -x "$current/$executable" && "$FORCE" == 0 ]] && (( now - last < 86400 )); then
        echo "$name: проверен сегодня."; exit 0
    fi
    # Check again before publishing an update.
    if own_app_running "$name" "$process"; then
        echo "$name: запущен; обновление отложено до следующего запуска установщика."; exit 0
    fi
    echo "$name: скачиваю текущий Stable…"
    download "$url" "$archive"
    hash="$(sha256sum "$archive" | cut -d ' ' -f 1)"
    version="$ROOT/apps/$name-$hash"
    if [[ ! -x "$version/$executable" ]]; then
        stage="$WORK/$name-unpack"
        mkdir -p "$stage"
        if [[ "$name" == discord ]]; then
            tar -xzf "$archive" --no-same-owner -C "$stage"
            if [[ ! -x "$stage/Discord/Discord" &&
                  -x "$stage/Discord/discord" &&
                  -x "$stage/Discord/updater_bootstrap" ]]; then
                echo 'Discord: архив содержит официальный bootstrap; скачиваю приложение…'
                prepare_discord_runtime "$stage/Discord/updater_bootstrap"
                # The official lowercase launcher handles app-* directories and updates.
                cat > "$stage/Discord/Discord" <<'LAUNCH'
#!/bin/bash
root="/goinfre/$(id -un)"
export XDG_CONFIG_HOME="$root/runtime-config"
exec "$(dirname "$(readlink -f "$0")")/discord" "$@"
LAUNCH
                chmod 700 "$stage/Discord/Discord"
            fi
            [[ -x "$stage/Discord/Discord" ]] || {
                echo 'Неизвестный формат Discord. Файлы архива:'
                tar -tzf "$archive" | head -n 30
                exit 1
            }
            mv "$stage/Discord" "$version"
        else
            dpkg-deb -x "$archive" "$stage"
            [[ -x "$stage/$executable" ]]
            mv "$stage" "$version"
        fi
    fi
    if own_app_running "$name" "$process"; then
        echo "$name: приложение запущено; новая версия подготовлена, переключение отложено."; exit 0
    fi
    [[ ! -L "$current" ]] || previous="$(readlink "$current")"
    ln -s "$version" "$WORK/$name-link"
    mv -Tf "$WORK/$name-link" "$current"
    if [[ -n "$previous" && "$previous" != "$version" ]]; then
        ln -s "$previous" "$WORK/$name-previous"
        mv -Tf "$WORK/$name-previous" "$ROOT/apps/$name-previous"
    fi
    printf '%s\n' "$now" > "$stamp"
    echo "$name: готово."
)
FORCE=0
[[ "${1:-}" != --force-update ]] || FORCE=1
FAILURES=0
if [[ "$MODE" != --chatgpt-only ]]; then
set +e
update_app discord 'https://discord.com/api/download/stable?platform=linux&format=tar.gz' 'Discord|discord' Discord
result=$?
set -e
if (( result != 0 )); then
    echo 'Discord: обновить не удалось, старая копия сохранена.'; FAILURES=1
fi
set +e
update_app chrome 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb' chrome opt/google/chrome/chrome
result=$?
set -e
if (( result != 0 )); then
    echo 'Chrome: обновить не удалось, старая копия сохранена.'; FAILURES=1
fi


fi

# Reuse the already-working ChatGPT installation without copying its profile.
if [[ ! -x "$ROOT/apps/chatgpt/usr/lib/chatgpt/ChatGPT" &&
      -x "$ROOT/chatgpt-desktop/usr/lib/chatgpt/ChatGPT" ]]; then
    ln -s "$ROOT/chatgpt-desktop" "$WORK/chatgpt-legacy-link"
    mv -Tf "$WORK/chatgpt-legacy-link" "$ROOT/apps/chatgpt"
    date +%s > "$ROOT/apps/.chatgpt-checked"
    echo 'ChatGPT: существующая установка подключена; профиль сохранён.'
fi
set +e
update_app chatgpt 'https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb' 'ChatGPT|chatgpt' usr/lib/chatgpt/ChatGPT
result=$?
set -e
if (( result != 0 )); then
    echo 'ChatGPT: установка/обновление не завершено; существующая копия сохранена.'; FAILURES=1
fi

cat > "$BIN/42-gpt" <<'GPT_LAUNCH'
#!/bin/bash
set -Eeuo pipefail
umask 077
root="/goinfre/$(id -un)"
app="$root/apps/chatgpt/usr/lib/chatgpt/ChatGPT"
[[ -x "$app" ]] || app="$root/chatgpt-desktop/usr/lib/chatgpt/ChatGPT"
[[ -x "$app" ]] || { echo 'ChatGPT ещё не установлен. Запусти 42-setup --chatgpt-only.'; exit 1; }
export XDG_CONFIG_HOME="$root/chatgpt-data/config"
export XDG_CACHE_HOME="$root/chatgpt-data/cache"
export XDG_DATA_HOME="$root/chatgpt-data/share"
export CODEX_HOME="$root/codex"
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$CODEX_HOME" "$root/chatgpt-data/profile"
cd "$(dirname "$app")"
exec "$app" --user-data-dir="$root/chatgpt-data/profile" "$@"
GPT_LAUNCH
chmod 700 "$BIN/42-gpt"
# Keep the user's existing /goinfre/bin PATH entry pointing at the new launcher.
mkdir -p "$ROOT/bin"
if [[ -f "$ROOT/bin/42-gpt" ]] && ! grep -Fq '# 42-env launcher bridge' "$ROOT/bin/42-gpt"; then
    mkdir -p "$STATE/backups"
    cp -p "$ROOT/bin/42-gpt" "$STATE/backups/42-gpt-$(date +%Y%m%d-%H%M%S)"
fi
cat > "$ROOT/bin/42-gpt" <<'GPT_BRIDGE'
#!/bin/bash
# 42-env launcher bridge
exec "$HOME/.local/bin/42-gpt" "$@"
GPT_BRIDGE
chmod 700 "$ROOT/bin/42-gpt"
mkdir -p "$HOME/.local/share/applications"
escaped_gpt="$BIN/42-gpt"
escaped_gpt="${escaped_gpt//\\/\\\\}"
escaped_gpt="${escaped_gpt//\"/\\\"}"
cat > "$HOME/.local/share/applications/42-chatgpt.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=ChatGPT (42)
Exec="$escaped_gpt"
Icon=applications-internet
Terminal=false
Categories=Development;Utility;
EOF
if [[ "$MODE" == --chatgpt-only ]]; then
    echo "ChatGPT: запуск $BIN/42-gpt"
    exit "$FAILURES"
fi

# Explicit launchers always use our copies, regardless of system installations.
cat > "$BIN/42-discord" <<'EOF'
#!/bin/bash
app="/goinfre/$(id -un)/apps/discord/Discord"
[[ -x "$app" ]] || { echo 'Сначала запусти 42-setup.'; exit 1; }
exec "$app" "$@"
EOF
cat > "$BIN/42-chrome" <<'EOF'
#!/bin/bash
app="/goinfre/$(id -un)/apps/chrome/opt/google/chrome/chrome"
[[ -x "$app" ]] || { echo 'Сначала запусти 42-setup.'; exit 1; }
# A separate profile prevents the running system browser from receiving our launch.
exec "$app" --user-data-dir="$HOME/.config/42-chrome" "$@"
EOF
chmod 700 "$BIN/42-discord" "$BIN/42-chrome"

# Discord uses runtime-config; register the browser there as well.
/usr/bin/python3 <<'PY_BROWSER'
import configparser
import os
from pathlib import Path
import pwd

home = Path.home()
root = Path('/goinfre') / pwd.getpwuid(os.getuid()).pw_name
applications = home / '.local/share/applications'
applications.mkdir(parents=True, exist_ok=True)
launcher = str(home / '.local/bin/42-chrome').replace('\\', '\\\\').replace('"', '\\"').replace('%', '%%')
(applications / '42-chrome.desktop').write_text(
    '[Desktop Entry]\nType=Application\nName=42 Chrome\nExec=/usr/bin/env "' + launcher + '" %U\n'
    'Terminal=false\nCategories=Network;WebBrowser;\n'
    'MimeType=application/pdf;text/html;x-scheme-handler/http;x-scheme-handler/https;\n')
for directory in [home / '.config', root / 'runtime-config']:
    directory.mkdir(parents=True, exist_ok=True)
    target = directory / 'mimeapps.list'
    settings = configparser.ConfigParser(interpolation=None, strict=False)
    settings.optionxform = str
    if target.exists():
        settings.read(target)
    if not settings.has_section('Default Applications'):
        settings.add_section('Default Applications')
    for mime in ['application/pdf', 'text/html', 'x-scheme-handler/http', 'x-scheme-handler/https']:
        settings['Default Applications'][mime] = '42-chrome.desktop'
    temporary = target.with_name('mimeapps.list.42-new')
    with temporary.open('w') as output:
        settings.write(output, space_around_delimiters=False)
    temporary.replace(target)
print('HTTP/HTTPS links use 42 Chrome in the desktop and Discord profiles.')
PY_BROWSER
ln -sfn 42-discord "$BIN/discord"
ln -sfn 42-chrome "$BIN/google-chrome"

setup_cli() (
    set -Eeuo pipefail
    trap - EXIT
    # ~/.cache can point to a missing per-workstation /goinfre directory.
    if [[ -L "$HOME/.cache" && ! -e "$HOME/.cache" ]]; then
        mkdir -p -- "$(readlink -m "$HOME/.cache")"
    fi
    if [[ ! -x "$BREW/bin/brew" ]]; then
        echo 'Устанавливаю Homebrew без sudo…'
        download https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh "$WORK/install-brew.sh"
        NONINTERACTIVE=1 /bin/bash "$WORK/install-brew.sh" --path "$BREW"
    fi
    eval "$("$BREW/bin/brew" shellenv)"
    for package in gh hello ffmpeg python@3.12; do
        if ! brew list --versions "$package" >/dev/null 2>&1; then
            brew install "$package"
        fi
    done
    local python venv="$ROOT/venvs/whisper"
    python="$(brew --prefix python@3.12)/bin/python3.12"
    [[ -x "$venv/bin/python" ]] || "$python" -m venv "$venv"
    if ! "$venv/bin/python" -c 'import faster_whisper' >/dev/null 2>&1; then
        "$venv/bin/python" -m pip install faster-whisper
    fi
    if [[ ! -f "$ROOT/models/small/.ready" || ! -s "$ROOT/models/small/model.bin" ]]; then
        "$venv/bin/python" - "$ROOT/models/small" <<'PY'
import sys
from faster_whisper import WhisperModel
from faster_whisper.utils import download_model
path = download_model('small', output_dir=sys.argv[1])
WhisperModel(path, device='cpu', compute_type='int8', cpu_threads=4)
PY
        touch "$ROOT/models/small/.ready"
    fi
)
set +e
setup_cli
result=$?
set -e
if (( result != 0 )); then
    echo 'Brew/Whisper: установка не завершена, повтори 42-setup.'; FAILURES=1
fi

cat > "$BIN/42-transcribe.py" <<'PY'
import argparse
import os
from pathlib import Path
from faster_whisper import WhisperModel

p = argparse.ArgumentParser(description='Local CPU transcription')
p.add_argument('audio', type=Path)
p.add_argument('--language', default=None, help='ru, en, hy; omit for autodetection')
p.add_argument('--output', required=True, type=Path)
a = p.parse_args()
if not a.audio.is_file():
    p.error('Audio file does not exist')
if a.output.exists():
    p.error('Output already exists; choose another filename')
model_dir = Path('/goinfre') / os.environ['USER'] / 'models' / 'small'
model = WhisperModel(str(model_dir), device='cpu', compute_type='int8', cpu_threads=4)
segments, info = model.transcribe(str(a.audio), language=a.language, vad_filter=True)
print('Language:', info.language, flush=True)
with a.output.open('x', encoding='utf-8') as out:
    for s in segments:
        line = f'[{s.start:.1f}–{s.end:.1f}] {s.text.strip()}'
        print(line, flush=True)
        out.write(line + '\n')
        out.flush()
PY
cat > "$BIN/42-transcribe" <<'EOF'
#!/bin/bash
exec "/goinfre/$(id -un)/venvs/whisper/bin/python" "$HOME/.local/bin/42-transcribe.py" "$@"
EOF
chmod 700 "$BIN/42-transcribe"

cat > "$BIN/42-record" <<'EOF'
#!/bin/bash
# Records separate microphone/system tracks. Never changes default devices.
set -Eeuo pipefail
umask 077
mode="${1:-}"; output="${2:-}"
[[ "$mode" =~ ^(mic|system|both)$ && -n "$output" ]] || {
    echo 'Usage: 42-record mic|system|both NEW_OUTPUT_DIRECTORY'; exit 2;
}
source_name="$(pactl get-default-source)"
sink="$(pactl get-default-sink)"
if [[ "$mode" != system ]]; then
    source_name="${MIC_SOURCE:-$source_name}"
    [[ -n "$source_name" && "$source_name" != *.monitor ]] || {
        echo 'Микрофон не выбран. pactl list short sources; затем MIC_SOURCE=имя 42-record …'; exit 1;
    }
fi
if [[ "$mode" != mic ]]; then
    [[ "$sink" != auto_null ]] || { echo 'Виден только Dummy Output. Сначала исправь звук.'; exit 1; }
    monitor="$(pactl list short sinks | awk -v name="$sink" '$2==name {print $2 ".monitor"}')"
    [[ -n "$monitor" ]] || { echo 'Monitor-источник не найден.'; exit 1; }
fi
mkdir "$output"
pids=()
cleanup() {
    trap - INT TERM EXIT
    for pid in "${pids[@]}"; do kill -INT "$pid" 2>/dev/null || true; done
    for pid in "${pids[@]}"; do wait "$pid" 2>/dev/null || true; done
    echo "Записи: $output"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
if [[ "$mode" != system ]]; then
    parecord --device="$source_name" --file-format=wav --rate=16000 --channels=1 "$output/mic.wav" &
    pids+=("$!")
fi
if [[ "$mode" != mic ]]; then
    parecord --device="$monitor" --file-format=wav --rate=16000 --channels=1 "$output/system.wav" &
    pids+=("$!")
fi
echo 'Идёт запись. Ctrl+C — остановить обе дорожки.'
while true; do
    for pid in "${pids[@]}"; do
        kill -0 "$pid" 2>/dev/null || { echo 'Один из процессов записи остановился.'; exit 1; }
    done
    sleep 1
done
EOF
chmod 700 "$BIN/42-record"
if (( FAILURES )); then
    echo 'Часть установки завершилась ошибкой. См. лог и повтори 42-setup.'
    exit 1
fi
echo "Готово. Запуск: $BIN/42-chrome, $BIN/42-discord и $BIN/42-gpt"
echo 'Предыдущие версии приложений сохранены в /goinfre; при необходимости их можно удалить вручную.'
