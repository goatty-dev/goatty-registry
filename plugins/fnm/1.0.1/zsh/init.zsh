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
    # fnm skips a package.json without an engines field, so we skip it too.
    [[ $_goatty_fnm_resolve_engines == true && -f $1/package.json ]] &&
      [[ $(<$1/package.json) == *'"engines"'* ]]
  }

  _goatty_fnm_autoload_hook() {
    if [[ $_goatty_fnm_strategy == local ]]; then
      # Same as fnm's own local hook: only switch inside a project folder.
      _goatty_fnm_has_version_file . || return 0
    elif [[ ! -e $FNM_DIR/aliases/default ]]; then
      # No usable default to fall back to: switch only when a version file
      # exists here or in a parent folder.
      local dir=$PWD
      until _goatty_fnm_has_version_file $dir; do
        [[ $dir == / ]] && return 0
        dir=${dir:h}
      done
    fi
    fnm use --silent-if-unchanged
  }

  autoload -Uz add-zsh-hook
  add-zsh-hook -D chpwd _goatty_fnm_autoload_hook
  add-zsh-hook chpwd _goatty_fnm_autoload_hook
fi
