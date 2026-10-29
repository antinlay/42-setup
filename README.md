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

## MacTahoe desktop theme

`--enable` also registers `42-theme.desktop`, which runs `42-setup --theme`
at every GNOME login. Run `bash 42-setup.sh --theme` to apply it immediately.
It installs MacTahoe Dark, WhiteSur icons, left window buttons and a compact
bottom dock that hides automatically. Existing wallpapers are preserved.

Theme operations explicitly use system GNOME tools and the real user config,
even when launched from an app with custom XDG directories. The standalone script embeds a SHA-256 verified archive; installation and
subsequent logins work without network access, using the home-directory cache. Previous GNOME settings
are saved in `~/.local/share/42-env/theme/before.ini`. Logs are in
`~/.local/state/42-env/theme.log`. `--disable` removes the theme autostart too.

The Shell CSS is compiled for campus GNOME 42; on other GNOME major versions
only GTK and icons are selected, with a warning in the log. User Themes and
Ubuntu Dock must be available for the Shell and dock settings. Applications
with their own UI, such as Electron apps, may retain their own styling.

Bundled artwork sources:
- [MacTahoe](https://github.com/vinceliuice/MacTahoe-gtk-theme/tree/1e45e19f510edb8cde18fa84d6cd5319f60b086b), MIT.
- [WhiteSur icons](https://github.com/vinceliuice/WhiteSur-icon-theme/tree/73d8040da51a9ed74e47c7366e7e9ff437601a5c), GPL-3.0.

Licenses and the compressed assets are in `assets/themes/`.
