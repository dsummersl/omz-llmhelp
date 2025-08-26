_llmhelp_setup_pyenv() {
  # Check if pyenv is installed
  if ! command -v pyenv >/dev/null 2>&1; then
    echo "Error: llmhelp requires pyenv. Please install pyenv to continue." >&2
    exit 1
  fi

  # Install Python version if not already installed
  if ! pyenv versions --bare | grep -q "^$PYTHON_VERSION$"; then
    pyenv install "$PYTHON_VERSION"
  fi

  # Create virtualenv if not already present
  if ! pyenv virtualenvs --bare | grep -q "^$PYENV_NAME$"; then
    pyenv virtualenv "$PYTHON_VERSION" "$PYENV_NAME"
    PYENV_VERSION=$PYTHON_VERSION pyenv exec pip install llm llm-gemini glow
  fi
}
