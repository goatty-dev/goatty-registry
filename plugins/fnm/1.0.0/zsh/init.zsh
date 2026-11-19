# fnm for goatty: puts the active Node.js version on PATH and optionally
# switches versions automatically when changing directories.
# $goatty_settings values are fixed choices/bools validated from plugin.toml.
() {
  local -a flags=(
    --shell zsh
    "--version-file-strategy=${goatty_settings[version_file_strategy]}"
    "--resolve-engines=${goatty_settings[resolve_engines]}"
  )
  [[ ${goatty_settings[use_on_cd]} == true ]] && flags+=(--use-on-cd)
  [[ ${goatty_settings[corepack_enabled]} == true ]] && flags+=(--corepack-enabled)
  eval "$(fnm env "${flags[@]}")"
}
