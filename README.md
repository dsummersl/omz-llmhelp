# omz-llmhelp

Oh My Zsh helper function for the llm CLI tool

A simple Oh My Zsh plugin that adds a `llmhelp` function to get help on the terminal using the [llm](https://llm.datasette.io) CLI tool.

This is a wrapper around the `llm` CLI tool to provide help in a terminal. It is provided context from your current terminal session to give more relevant help:

- The `!!` and `!$` history expansions are supported to provide context from the last command run and its success/failure.
- If you run your sessions within `tmux` the current screen content is also provided as context.

## Installation

1. Clone this repository into your custom Oh My Zsh plugins directory:

```bash
git clone [https://github.com/dsummersl/omz-llmhelp](https://github.com/dsummersl/omz-llmhelp.git) ~/.oh-my-zsh/custom/plugins/llmhelp
```

2. Add `omz-llmhelp` to the plugins array in your `~/.zshrc` file:

```bash
plugins=(... llmhelp)
```

3. Restart your terminal or run `source ~/.zshrc` to apply the changes.
