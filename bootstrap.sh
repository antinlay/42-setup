#!/usr/bin/env bash
# Download only when missing; existing installations also work offline.
set -Eeuo pipefail
umask 077
export PATH="/usr/bin:/bin:$PATH"
[[ "$EUID" != 0 ]] || { echo 'Запускай без sudo.' >&2; exit 1; }
bin="$HOME/.local/bin"
mkdir -p "$bin"
exec 8>"$bin/.42-bootstrap.lock"
flock 8
target="$bin/42-setup"
if [[ ! -s "$target" ]]; then
    root="/goinfre/$(id -un)"
    [[ -d /goinfre && -w /goinfre ]] || { echo '/goinfre недоступен.' >&2; exit 1; }
    mkdir -p "$root"
    [[ -O "$root" && ! -L "$root" ]] || exit 1
    mkdir -p "$root/tmp"
    stage="$(mktemp -d "$root/tmp/42-bootstrap.XXXXXX")"
    install_stage=""
    trap 'rm -rf -- "$stage"; if [[ -n "$install_stage" ]]; then rm -f -- "$install_stage"; fi' EXIT
    GIT_TERMINAL_PROMPT=0 git -c credential.helper= clone --depth 1 \
        https://github.com/antinlay/42-setup.git "$stage/repo"
    bash -n "$stage/repo/42-setup.sh"
    install_stage="$(mktemp "$bin/.42-setup.XXXXXX")"
    install -m 700 "$stage/repo/42-setup.sh" "$install_stage"
    mv -f -- "$install_stage" "$target"
    rm -rf -- "$stage"
    trap - EXIT
fi
flock -u 8
exec 8>&-
exec /bin/bash "$target" "$@"
