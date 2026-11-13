# tldr for goatty: Alt+T adds `tldr ` in front of the current command line
# (or removes it when already present) and keeps the cursor at the same spot.
_goatty_tldr_widget() {
  local -i cursor=$CURSOR
  if [[ $BUFFER == "tldr "* ]]; then
    BUFFER=${BUFFER#tldr }
    CURSOR=$(( cursor > 5 ? cursor - 5 : 0 ))
  elif [[ $BUFFER == "tldr" ]]; then
    BUFFER=""
    CURSOR=0
  else
    BUFFER="tldr $BUFFER"
    CURSOR=$(( cursor + 5 ))
  fi
}

if (( $+builtins[zle] )); then
  zle -N _goatty_tldr_widget
  bindkey '^[t' _goatty_tldr_widget
  bindkey '^[T' _goatty_tldr_widget
fi
