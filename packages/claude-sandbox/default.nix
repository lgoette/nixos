{
  writeShellScriptBin,
  bubblewrap,
  claude-code,
}:

writeShellScriptBin "claude-sandbox" ''
  if [ -n "$1" ] && [ -d "$1" ]; then
    PROJECT_DIR="$1"
    shift
  else
    PROJECT_DIR="$(pwd)"
  fi

  exec ${bubblewrap}/bin/bwrap \
    --ro-bind /nix/store /nix/store \
    --ro-bind /etc /etc \
    --ro-bind /run/current-system /run/current-system \
    --ro-bind /run/wrappers /run/wrappers \
    --ro-bind /run/systemd/resolve /run/systemd/resolve \
    --symlink /run/current-system/sw/bin /bin \
    --symlink /run/current-system/sw/lib /lib \
    --tmpfs "$HOME" \
    --bind "$HOME/.claude" "$HOME/.claude" \
    --bind "$HOME/.claude.json" "$HOME/.claude.json" \
    --ro-bind-try "$HOME/.gitconfig" "$HOME/.gitconfig" \
    --bind "$PROJECT_DIR" "$PROJECT_DIR" \
    --tmpfs /tmp \
    --proc /proc \
    --dev /dev \
    --share-net \
    --unshare-pid \
    --die-with-parent \
    --chdir "$PROJECT_DIR" \
    --ro-bind /dev/null "$PROJECT_DIR/.env" \
    --ro-bind /dev/null "$PROJECT_DIR/.env.local" \
    --ro-bind /dev/null "$PROJECT_DIR/.env.production" \
    ${claude-code}/bin/claude "$@"
''
