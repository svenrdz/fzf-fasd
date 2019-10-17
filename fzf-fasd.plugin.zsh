# fzf-fasd integration
# author: @wookayin
# vim: set ft=zsh ts=2 sts=2 ts=2:

# fasd+fzf integration (ZSH only)
__fzf_fasd_zsh_completion() {
  local args cmd slug selected

  args=(${(z)LBUFFER})
  cmd=${args[1]}

  typeset -A funs_map=(
    f f
    a a
    s s
    d d
    z d
    j d
    v f
    V f
  )

  fzf_fasd_fun=${funs_map[$cmd]}

  # echo "[DEBUG args] ${args[@]}"
  # echo "[DEBUG cmd] $cmd"
  # echo "[DEBUG fun] $fzf_fasd_fun"

  # triggered only at commands defined in funs; fallback to default
  if [[ ! $fzf_fasd_fun ]]; then
    zle ${__fzf_fasd_default_completion:-expand-or-complete}
    return
  fi

  if [[ "${#args}" -gt 1 ]]; then
    eval "slug=${args[-1]}"
  fi

  # generate completion list from fasd
  local matches_count
  if [[ $fzf_fasd_fun == f ]]; then
    matches_count=$(__fzf_fasd_generate_matches_f "$slug" | head | wc -l)
  elif [[ $fzf_fasd_fun == a ]]; then
    matches_count=$(__fzf_fasd_generate_matches_a "$slug" | head | wc -l)
  elif [[ $fzf_fasd_fun == s ]]; then
    matches_count=$(__fzf_fasd_generate_matches_s "$slug" | head | wc -l)
  elif [[ $fzf_fasd_fun == d ]]; then
    matches_count=$(__fzf_fasd_generate_matches_d "$slug" | head | wc -l)
  fi
  if [[ "$matches_count" -gt 1 ]]; then
    # >1 results, invoke fzf
    if [[ $fzf_fasd_fun == f ]]; then
      selected=$(__fzf_fasd_generate_matches_f "$slug" \
          | fzf --query="$slug" --reverse --bind 'shift-tab:up,tab:down' --height '50%'
      )
    elif [[ $fzf_fasd_fun == a ]]; then
      selected=$(__fzf_fasd_generate_matches_a "$slug" \
          | fzf --query="$slug" --reverse --bind 'shift-tab:up,tab:down' --height '50%'
      )
    elif [[ $fzf_fasd_fun == s ]]; then
      selected=$(__fzf_fasd_generate_matches_s "$slug" \
          | fzf --query="$slug" --reverse --bind 'shift-tab:up,tab:down' --height '50%'
      )
    elif [[ $fzf_fasd_fun == d ]]; then
      selected=$(__fzf_fasd_generate_matches_d "$slug" \
          | fzf --query="$slug" --reverse --bind 'shift-tab:up,tab:down' --height '50%'
      )
    fi
  elif [[ "$matches_count" -eq 1 ]]; then
    # 1 result, just complete it
    if [[ $fzf_fasd_fun == f ]]; then
      selected=$(__fzf_fasd_generate_matches_f "$slug")
    elif [[ $fzf_fasd_fun == a ]]; then
      selected=$(__fzf_fasd_generate_matches_a "$slug")
    elif [[ $fzf_fasd_fun == s ]]; then
      selected=$(__fzf_fasd_generate_matches_s "$slug")
    elif [[ $fzf_fasd_fun == d ]]; then
      selected=$(__fzf_fasd_generate_matches_d "$slug")
    fi
  else;
    # no result
    return
  fi
  # echo "[DEBUG] $selected $matches_count"

  # return completion result with $selected
  if [[ -n "$selected" ]]; then
    selected=$(printf %q "$selected")
    if [[ "$selected" == */ ]]; then
      selected="${selected%/}"
    fi
    LBUFFER="$cmd $selected"
  fi

  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init && zle accept-line
}

__fzf_fasd_generate_matches_f() {
  # -R: make entries with higher score comes earlier
  fasd -f -l -R "$@"
}

__fzf_fasd_generate_matches_a() {
  # -R: make entries with higher score comes earlier
  fasd -a -l -R "$@"
}

__fzf_fasd_generate_matches_s() {
  # -R: make entries with higher score comes earlier
  fasd -s -l -R "$@"
}

__fzf_fasd_generate_matches_d() {
  # -R: make entries with higher score comes earlier
  fasd -d -l -R "$@"
}

[ -z "$__fzf_fasd_default_completion" ] && {
  binding=$(bindkey '^I')
  [[ $binding =~ 'undefined-key' ]] || __fzf_fasd_default_completion=$binding[(s: :w)2]
  unset binding
}

zle      -N  __fzf_fasd_zsh_completion
bindkey '^I' __fzf_fasd_zsh_completion
