source "${0:A:h}/lib/pyenv.zsh"

llmhelp() {
  local PYTHON_VERSION="3.11.9"
  local PYENV_NAME="llmhelp"

  local rc=$?                           # exit code of previous command
  local -a ps=("${pipestatus[@]}")      # per-stage pipeline statuses
  local cmd; cmd=$(fc -ln -1)           # literal previous command
  local lines=20

  _llmhelp_setup_pyenv || return 1

  # Optional user-supplied prompt text; else a default
  local query="${*:-Can you correct the previous command or explain why it won't work?}"

  # Set useglow to true if query starts with 'explain'
  local useglow=false; [[ "$query" == explain* ]] && useglow=true

  # Base info
  local info
  info=$(
    printf 'Previous command:\n%s\n\nExit code: %d\nPipeline statuses: %s\nCWD: %s\nShell: zsh\n' \
      "$cmd" "$rc" "${ps[*]:-n/a}" "$PWD"
  )

  # If in tmux, append the active pane context
  if [[ -n "$TMUX" ]]; then
    local id meta content
    id=$(tmux list-panes -F '#{?pane_active,#{pane_id},}' | grep -v '^$' | head -n1)
    if [[ -n "$id" ]]; then
      meta=$(tmux display-message -p -t "$id" \
        '* pane #{pane_index} #{pane_width}x#{pane_height} | cmd=#{pane_current_command} | title="#{pane_title}" | tty=#{pane_tty}')
      content=$(tmux capture-pane -ep -S -"${lines}" -t "$id" 2>/dev/null || echo "<unable to capture>")
      info+=$'\n\n'"=== tmux active pane (last '"$lines"' lines) ==="$'\n'"--- ${meta} ---"$'\n'"${content}"
    fi
  fi

  # One clean string to llm
  local payload="$query"$'\n\n'"$info"
  if [[ "$useglow" == false ]]; then
    PYENV_VERSION=$PYTHON_VERSION pyenv exec llm -t clilookup "$payload" | tee >(pbcopy)
  else
    PYENV_VERSION=$PYTHON_VERSION pyenv exec llm -t clilookup "$payload" | glow
  fi
}
