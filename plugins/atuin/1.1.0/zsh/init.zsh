# Atuin for goatty: records commands and binds its search. goatty sources
# this in every goatty shell, after its fzf bindings. While it runs,
# $goatty_settings holds this plugin's settings (bools: "true"/"false").
() {
  local -a flags
  [[ $goatty_settings[ctrl_r] == true ]] || flags+=(--disable-ctrl-r)
  [[ $goatty_settings[up_arrow] == true ]] || flags+=(--disable-up-arrow)
  [[ $goatty_settings[ai] == true ]] || flags+=(--disable-ai)
  eval "$(atuin init zsh $flags)"
}
