# Docker completion and piped aliases for goatty. Sourced in goatty shells
# (after compinit) when docker is installed.
#
# `docker completion zsh` takes a moment, so its output is cached and only
# regenerated when the docker binary is newer than the cache.
if [[ ${goatty_settings[completion]} == true ]]; then
  () {
    local cache=${XDG_CACHE_HOME:-$HOME/.cache}/goatty/docker-completion.zsh
    if [[ ! -s $cache || $commands[docker] -nt $cache ]]; then
      command mkdir -p -- ${cache:h} || return 0
      docker completion zsh >| $cache.tmp 2>/dev/null && command mv -f -- $cache.tmp $cache || { command rm -f -- $cache.tmp; return 0 }
    fi
    builtin source -- $cache
  }
fi

if [[ ${goatty_settings[aliases]} == true ]]; then
  alias -- dsa='docker ps -q | xargs -r docker stop'
  alias -- dxa='docker ps -aq | xargs -r docker rm'
fi
