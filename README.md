# 42 setup

User-level Ubuntu GNOME/X11 workstation setup for 42 campus computers.
Run without sudo. Includes portable tools, desktop startup, keyboard shortcuts,
campus lock integration and display scaling.

Public download and installation (no GitHub login required):

```sh
git clone https://github.com/antinlay/42-setup.git /goinfre/$(id -un)/42-setup
bash /goinfre/$(id -un)/42-setup/bootstrap.sh --enable
~/.local/bin/42-bootstrap
```

`--enable` installs the script and registers login startup. The last command
installs/updates applications immediately. The bootstrap uses a shallow public HTTPS `git clone` to download `42-setup`
only if the installed copy is missing, checks Bash syntax, and installs it
atomically. Login startup uses the same bootstrap, so a missing installed script
is recovered automatically when the network is available. Existing copies work
offline. Keep `~/.local/bin/42-bootstrap` for this recovery path.

```sh
~/.local/bin/42-bootstrap --keyboard
~/.local/bin/42-bootstrap --storage-only
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
bottom dock that hides automatically. The bundled `assets/walp.png` is applied to the desktop (light and dark modes)
and the standard GNOME lock screen. The separate campus `ft_lock` may use its own background.

Theme operations explicitly use system GNOME tools and the real user config,
even when launched from an app with custom XDG directories. The standalone script embeds a SHA-256 verified archive; installation and
subsequent logins work without network access, using the `/goinfre` cache. Previous GNOME settings
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

## Storage

Large app profiles, VS Code extensions, setup state/backups and theme archives
are migrated to `/goinfre/$(id -un)/home-storage`. Original home paths become
symlinks. The desktop cache is `/goinfre/$(id -un)/cache/desktop`; temporary
files and package/model caches also use `/goinfre`. Open application profiles
are deferred until a subsequent run after the application closes. Existing
source and destination directories are never merged automatically.

Small desktop settings, themes/icons, launchers and personal files remain in
home. `/goinfre` is local workstation storage: profiles stored there are not
synchronized to other campus computers and may be removed by campus cleanup.

## Vim and GNOME Terminal

`bash 42-setup.sh --editor` installs the bundled Vim configuration and the
complete `lebowski` GNOME Terminal profile, including **Liberation Mono 12**,
colors, transparency, cursor, scrollback and cell spacing. The profile is made
default; other profiles remain available. The snapshot includes effective
settings as well as customized values. Unsupported or locked settings on a
different GNOME version are skipped with a message. Liberation Mono must be
installed on the workstation (provided on the campus Ubuntu image).

Vim uses an Xcode-inspired dark syntax palette with the terminal's background.
C/C++ (including `.h`) use real tabs with width 4. Includes persistent undo,
backups, Ctrl-S save, Ctrl-P file completion, Ctrl-B explorer, Space-f project
search (requires `rg`) and Space-y clipboard copy (native clipboard or X11
`xclip`). Function/type semantic highlighting is limited by built-in Vim syntax.
The 42 header shortcut uses an existing `Stdheader` plugin if available.

`--enable` applies these settings immediately and registers `42-editor.desktop`
to restore them at each login. Full/background setup applies them too. Run
`--enable` again after updating an existing installation to register the new
autostart. Bootstrap keeps existing offline copies; it does not automatically
fetch repository updates. Copy a new `42-setup.sh` and rerun `--enable` to upgrade.
`--disable` removes the editor autostart along with the other startup entries.

Readable sources are in `assets/editor/`; run `python3 tools/bundle.py` after
editing them. The standalone script embeds all editor assets and needs no
network access for `--editor`. Changed Vim files are backed up under
`~/.local/state/42-env/editor/backups/`. The first terminal state is saved as
`~/.local/state/42-env/editor/terminal-before.json` (GVariant values for use with
`gsettings set`). Repeated identical runs do not create extra Vim backups.
Desktop-derived colors/transparency can vary with the workstation's GTK theme.
