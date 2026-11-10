# Docker completion for goatty. Sourced in goatty shells (after compinit)
# when the plugin's "Tab completion" setting is on and docker is installed.
#
# `docker completion zsh` takes a moment, so its output is cached and only
# regenerated when the docker binary is newer than the cache.
() {
  local cache=${XDG_CACHE_HOME:-$HOME/.cache}/goatty/docker-completion.zsh
  if [[ ! -s $cache || $commands[docker] -nt $cache ]]; then
    command mkdir -p -- ${cache:h} || return 0
    docker completion zsh >| $cache.tmp 2>/dev/null && command mv -f -- $cache.tmp $cache || { command rm -f -- $cache.tmp; return 0 }
  fi
  builtin source -- $cache
}
