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
