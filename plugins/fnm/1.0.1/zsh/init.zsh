# fnm for goatty: puts the active Node.js version on PATH and optionally
# switches versions automatically when changing directories.
# $goatty_settings values are fixed choices/bools validated from plugin.toml.
() {
  local -a flags=(
    --shell zsh
    "--version-file-strategy=${goatty_settings[version_file_strategy]}"
    "--resolve-engines=${goatty_settings[resolve_engines]}"
  )
  [[ ${goatty_settings[corepack_enabled]} == true ]] && flags+=(--corepack-enabled)
  eval "$(fnm env "${flags[@]}")"
}

# We install our own cd hook instead of passing --use-on-cd to fnm. fnm's hook
# for the "recursive" strategy runs `fnm use` on every cd. Outside a project
# that falls back to the `default` alias, and when no default exists yet (no
# Node.js installed) fnm asks to install "default" after every cd, which can't
# succeed (goatty-registry#15). This hook only runs `fnm use` when it has
# something to switch to.
if [[ ${goatty_settings[use_on_cd]} == true ]]; then
  typeset -g _goatty_fnm_strategy=${goatty_settings[version_file_strategy]}
  typeset -g _goatty_fnm_resolve_engines=${goatty_settings[resolve_engines]}

  # Does directory $1 hold a version file fnm would read?
  _goatty_fnm_has_version_file() {
    [[ -f $1/.node-version || -f $1/.nvmrc ]] && return 0
    # fnm only reads package.json for a string `engines.node` and skips the
    # file otherwise, so we do too.
    [[ $_goatty_fnm_resolve_engines == true && -f $1/package.json ]] &&
      [[ $(<$1/package.json) =~ '"engines"[[:space:]]*:[[:space:]]*\{[^}]*"node"[[:space:]]*:[[:space:]]*"' ]]
  }

  # Is there a default fnm can switch to? A link to a removed version isn't
  # one. `fnm default system` is a deliberately broken link to
  # /dev/null/installation, and that one is.
  _goatty_fnm_has_default() {
    local link=$FNM_DIR/aliases/default target
    [[ -e $link ]] && return 0
    [[ -L $link ]] || return 1
    zmodload -F zsh/stat b:zstat 2>/dev/null &&
      zstat -L -A target +link -- $link 2>/dev/null &&
      [[ $target == /dev/null/installation ]]
  }

  # Extra arguments go to `fnm use`.
  _goatty_fnm_autoload_hook() {
    if [[ $_goatty_fnm_strategy == local ]]; then
      # Same as fnm's own local hook: only switch inside a project folder.
      _goatty_fnm_has_version_file . || return 0
    elif ! _goatty_fnm_has_default; then
      # No usable default to fall back to: switch only when a version file
      # exists here or in a parent folder. Like fnm, walk the physical path.
      local dir=${PWD:A}
      until _goatty_fnm_has_version_file $dir; do
        [[ $dir == / ]] && return 0
        dir=${dir:h}
      done
    fi
    fnm use --silent-if-unchanged "$@"
  }

  autoload -Uz add-zsh-hook
  add-zsh-hook -D chpwd _goatty_fnm_autoload_hook
  add-zsh-hook chpwd _goatty_fnm_autoload_hook

  # Like fnm's --use-on-cd, pick the version for the folder the shell starts
  # in. Quietly and without asking: startup must not print or prompt.
  _goatty_fnm_autoload_hook --log-level=quiet </dev/null &>/dev/null
fi
