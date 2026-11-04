import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets/editor'
spec = importlib.util.spec_from_file_location('editor', ASSETS / 'install.py')
editor = importlib.util.module_from_spec(spec)
spec.loader.exec_module(editor)


class EditorInstallTests(unittest.TestCase):
    def test_install_backup_and_idempotency(self):
        assets = {name: (ASSETS / name).read_text() for name in ['vimrc', 'xcode_dark.vim']}
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            (home / '.vimrc').write_text('original config\n')
            state = editor.install(home, assets)
            self.assertEqual((home / '.vimrc').read_text(), assets['vimrc'])
            self.assertEqual((home / '.vim/colors/xcode_dark.vim').read_text(), assets['xcode_dark.vim'])
            backups = list((state / 'backups').iterdir())
            self.assertEqual(len(backups), 1)
            self.assertEqual(backups[0].read_text(), 'original config\n')
            editor.install(home, assets)
            self.assertEqual(list((state / 'backups').iterdir()), backups)

    def test_terminal_snapshot_matches_requested_profile(self):
        profile = json.loads((ASSETS / 'terminal-profile.json').read_text())
        self.assertEqual(profile['settings']['font'], "'Liberation Mono 12'")
        self.assertEqual(profile['settings']['visible-name'], "'lebowski'")
        self.assertEqual(profile['settings']['use-system-font'], 'false')
        self.assertIn('palette', profile['settings'])
        self.assertIn('scrollback-lines', profile['settings'])
