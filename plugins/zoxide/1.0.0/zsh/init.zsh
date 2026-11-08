# zoxide for goatty: defines the jump commands and the directory hook.
# goatty sources this in every goatty shell, after its own features. While it
# runs, $goatty_settings holds this plugin's settings; the choices are fixed
# in plugin.toml, so the values below are always one of them.
eval "$(zoxide init zsh --cmd "${goatty_settings[command]}" --hook "${goatty_settings[hook]}")"
