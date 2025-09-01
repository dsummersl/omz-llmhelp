llmhelp() {
  local LLMHELP_PYTHON_VERSION="3.11"
  local LLMHELP_LLM_TEMPLATE="llmhelp"

  local rc=$?                           # exit code of previous command
  local -a ps=("${pipestatus[@]}")      # per-stage pipeline statuses
  local cmd; cmd=$(fc -ln -1)           # literal previous command
  local lines=20

  # Check if uv is installed
  if ! command -v uv >/dev/null 2>&1; then
    echo "Error: llmhelp requires uv. Please install uv to continue." >&2
    exit 1
  fi

  # See if the `uv list tool` includes llm
  if ! uv tool list | grep -q '^llm\s'; then
    uv tool install --python $LLMHELP_PYTHON_VERSION --force llm --with "glow,llm-gemini"
  fi

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

  # Define the llmhelp template if not yet defined:
  if ! uv tool run llm templates show $LLMHELP_LLM_TEMPLATE &> /dev/null; then
    TEMPATE_DIR=$(uv tool run llm templates path)
    cat > "$TEMPATE_DIR/$LLMHELP_LLM_TEMPLATE.yaml" << 'EOF'
model: gemini-2.5-flash
name: llmhelp
system: "Act in two ways: lookup mode or explain mode.\n\nlookup mode (default behavior):\
    \ Act as a lookup tool for the CLI man pages/manual. If possible return the\n\
    exact command requested of the user, or corrected command only. If the command\n\
    does not exist, or cannot be achieved provide no more than one sentence describing\n\
    the conundrum. Do not use markdown or code fences. The output is intended to be\
    \ used directly on the CLI. \n\nexplain mode: If the prompt starts with 'explain',\
    \ provide a paragraph of guidance. Limit the response to\nno more than two paragraphs\
    \ (and a list, if applicable). The output is intended to be output directly\n\
    to a shell console. Use markdown. If sample commands are provided they should\
    \ be on their own \nline so that they're easy to copy and paste.\n"
EOF
  fi

  local payload="$query"$'\n\n'"$info"
  if [[ "$useglow" == false ]]; then
    uv tool run llm -t $LLMHELP_LLM_TEMPLATE "$payload" | tr -d '\n' | tee >(pbcopy)
  else
    uv tool run llm -t $LLMHELP_LLM_TEMPLATE "$payload" | glow
  fi
}
