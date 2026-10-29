import ast
import json
from pathlib import Path
import tempfile
import unittest
import sys

SCRIPT = Path(__file__).resolve().parents[1] / 'assets/keyboard/lock.py'

class RecoveryTest(unittest.TestCase):
    def run_recovery(self, display_error=False, locked=False, keyboard_error=False):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            pending = root / 'sources-before-lock.json'
            original = {'sources': "[('xkb', 'us'), ('xkb', 'ru')]", 'mru-sources': "[('xkb', 'ru')]", 'display': {'spec': ['old-host']}}
            pending.write_text(json.dumps(original))
            calls = []
            def put(key, value):
                if keyboard_error:
                    raise RuntimeError('settings unavailable')
                calls.append(key)
            def display(saved):
                self.assertEqual(calls, ['sources', 'mru-sources'])
                if display_error:
                    raise RuntimeError('Display topology changed')
            scope = dict(root=root, pending=pending, children=lambda: locked, put=put, apply_display=display, json=json, sys=sys)
            fn = next(n for n in ast.parse(SCRIPT.read_text()).body if isinstance(n, ast.FunctionDef) and n.name == 'restore')
            exec(compile(ast.Module(body=[fn], type_ignores=[]), str(SCRIPT), 'exec'), scope)
            if locked or keyboard_error:
                with self.assertRaises((SystemExit, RuntimeError)):
                    scope['restore']()
                self.assertTrue(pending.exists())
                return
            scope['restore']()
            self.assertFalse(pending.exists())
            self.assertEqual(calls, ['sources', 'mru-sources'])
            self.assertEqual((root / 'display-recovery-skipped.json').exists(), display_error)
    def test_changed_monitor(self): self.run_recovery(display_error=True)
    def test_same_monitor(self): self.run_recovery()
    def test_active_lock(self): self.run_recovery(locked=True)
    def test_settings_failure_keeps_backup(self): self.run_recovery(keyboard_error=True)

if __name__ == '__main__': unittest.main()
