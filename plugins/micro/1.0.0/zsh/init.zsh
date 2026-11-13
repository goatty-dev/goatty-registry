# micro for goatty:
# 1. When `clipboard` is "external", check before launching micro if the desktop
#    clipboard utility (wl-clipboard on Wayland, xclip/xsel on X11) is missing.
#    If missing in an interactive terminal, offer to install it or fall back to
#    terminal (OSC 52) clipboard without nagging again if dismissed.
# 2. When `sudoedit` is enabled, define `se` as a shortcut for `sudoedit`.

if [[ ${goatty_settings[sudoedit]} == true ]]; then
  function se {
    command sudoedit "$@"
  }
fi

if [[ ${goatty_settings[clipboard]} == external ]]; then
  function _goatty_micro_has_clipboard {
    (( $+commands[micro-clip] )) && return 0
    if [[ -n $WAYLAND_DISPLAY ]] && (( $+commands[wl-copy] && $+commands[wl-paste] )); then
      return 0
    fi
    if [[ -n $DISPLAY ]] && (( $+commands[xclip] || $+commands[xsel] )); then
      return 0
    fi
    return 1
  }

  function micro {
    if [[ -t 0 && -t 1 ]] && [[ -n $WAYLAND_DISPLAY || -n $DISPLAY ]] && ! _goatty_micro_has_clipboard; then
      local cache_dir=${_goatty_cache:-${XDG_CACHE_HOME:-$HOME/.cache}/goatty}
      local dismiss_file="$cache_dir/micro-clipboard-dismissed"
      if [[ ! -e $dismiss_file ]]; then
        local pkg display_kind
        local -a install_cmd
        if [[ -n $WAYLAND_DISPLAY ]]; then
          pkg=wl-clipboard
          display_kind=Wayland
        else
          pkg=xclip
          display_kind=X11
        fi

        if (( $+commands[pacman] )); then
          install_cmd=(sudo pacman -S --needed "$pkg")
        elif (( $+commands[apt] )); then
          install_cmd=(sudo apt install "$pkg")
        elif (( $+commands[dnf] )); then
          install_cmd=(sudo dnf install "$pkg")
        elif (( $+commands[zypper] )); then
          install_cmd=(sudo zypper install "$pkg")
        elif (( $+commands[apk] )); then
          install_cmd=(sudo apk add "$pkg")
        elif (( $+commands[xbps-install] )); then
          install_cmd=(sudo xbps-install -S "$pkg")
        elif (( $+commands[eopkg] )); then
          install_cmd=(sudo eopkg install "$pkg")
        elif (( $+commands[emerge] )); then
          if [[ $pkg == wl-clipboard ]]; then
            install_cmd=(sudo emerge gui-apps/wl-clipboard)
          else
            install_cmd=(sudo emerge x11-misc/xclip)
          fi
        fi

        builtin print -r -- $'\e[33mmicro:\e[0m system clipboard tool (\e[1m'"$pkg"$'\e[0m for '"$display_kind"$') is not installed.' >&2
        if (( ${#install_cmd} )); then
          local choice
          builtin print -rn -- "Install it now with \`${install_cmd[*]}\`? [Y/n/d(on't ask again)] " >&2
          builtin read -rk 1 choice </dev/tty 2>/dev/null || choice=n
          [[ $choice != $'\n' ]] && builtin print -r -- "" >&2
          case $choice in
            y|Y|$'\n')
              "${install_cmd[@]}"
              ;;
            d|D)
              [[ -d $cache_dir ]] || command mkdir -p -- "$cache_dir" 2>/dev/null
              : >| "$dismiss_file" 2>/dev/null
              builtin print -r -- $'\e[33mmicro:\e[0m using terminal clipboard (OSC 52) fallback; warning dismissed.' >&2
              ;;
          esac
        else
          builtin print -r -- "Install \`$pkg\` with your package manager so Ctrl+C / Ctrl+V can access your system clipboard (falling back to terminal clipboard)." >&2
          [[ -d $cache_dir ]] || command mkdir -p -- "$cache_dir" 2>/dev/null
          : >| "$dismiss_file" 2>/dev/null
        fi
      fi

      if ! _goatty_micro_has_clipboard; then
        command micro -clipboard=terminal "$@"
        return
      fi
    fi
    command micro "$@"
  }
fi
