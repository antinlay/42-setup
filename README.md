# 42 setup

User-level Ubuntu GNOME/X11 workstation setup for 42 campus computers.
Run without sudo. Includes portable tools, desktop startup, keyboard shortcuts,
campus lock integration and display scaling.

```sh
bash 42-setup.sh --enable
bash 42-setup.sh --keyboard
```

Keyboard sources include English and Russian; switch with Control+Space.
Keyboard recovery runs before display recovery. If a saved display belongs to
another workstation, its snapshot is kept in
`~/.local/share/mac-keyboard-fix/display-recovery-skipped.json`, and keyboard
setup continues. Active campus locks still defer keyboard recovery.

The standalone script embeds the readable Python files in `assets/`.
After editing those files, run `python3 tools/bundle.py` to rebuild it.

```sh
bash -n 42-setup.sh
python3 -m unittest discover -s tests -v
```

Desktop layout and launchers originate from this user's existing setup.
Review them before installing on another account.
