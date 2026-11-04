"""Refresh the standalone installer's embedded Python assets."""
import base64
import io
from pathlib import Path
import re
import zipfile
root = Path(__file__).resolve().parents[1]
buffer = io.BytesIO()
with zipfile.ZipFile(buffer, 'w', zipfile.ZIP_DEFLATED) as bundle:
    for path in sorted((root / 'assets').rglob('*.py')):
        bundle.write(path, path.relative_to(root / 'assets'))
script = root / '42-setup.sh'
script.write_text(re.sub(r'payload = "[^"]+"', 'payload = "' + base64.b64encode(buffer.getvalue()).decode() + '"', script.read_text()))

# Refresh the standalone wallpaper and its integrity checks.
import hashlib
wallpaper = (root / 'assets/walp.png').read_bytes()
text = script.read_text()
old = re.search(r'wallpaper_hash" != "([a-f0-9]{64})"', text).group(1)
text = text.replace(old, hashlib.sha256(wallpaper).hexdigest())
text = re.sub(r"(?<=<<'WALLPAPER_ASSET_42'\n).*?(?=WALLPAPER_ASSET_42\n)",
              lambda _: base64.encodebytes(wallpaper).decode(), text, flags=re.S)
script.write_text(text)

# Embed readable editor sources so the downloaded standalone script works offline.
import json
editor = root / 'assets/editor'
installer = (editor / 'install.py').read_text()
settings = {name: (editor / name).read_text() for name in ['vimrc', 'xcode_dark.vim', 'terminal-profile.json']}
program = installer + '\nmain(' + repr(settings) + ')\n'
block = '''# BEGIN 42 EDITOR
setup_editor() {
    /usr/bin/python3 - <<'PY_EDITOR_42'
import base64
exec(compile(base64.b64decode(%r), '<42-editor>', 'exec'))
PY_EDITOR_42
}
# END 42 EDITOR''' % base64.b64encode(program.encode()).decode()
text = script.read_text()
text = re.sub(r'# BEGIN 42 EDITOR\n.*?# END 42 EDITOR', lambda _: block, text, flags=re.S)
script.write_text(text)
