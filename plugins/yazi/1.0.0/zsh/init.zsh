# Yazi shell wrapper for goatty: `y` launches Yazi and changes your shell's
# working directory to where you navigated when you quit with `q` (press `Q`
# to quit without changing directory).
function y() {
  local tmp cwd rc
  tmp="$(command mktemp -t "yazi-cwd.XXXXXX")" || return
  {
    command yazi "$@" --cwd-file="$tmp"
    rc=$?
    IFS= read -r -d '' cwd < "$tmp"
    if [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]]; then
      builtin cd -- "$cwd"
    fi
  } always {
    command rm -f -- "$tmp"
  }
  return $rc
}
