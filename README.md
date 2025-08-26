# omz-llmhelp

Oh My Zsh helper function for the llm CLI tool

A simple Oh My Zsh plugin that adds a `llmhelp` function to get help on the terminal using the [llm](https://llm.datasette.io) CLI tool.

This is a wrapper around the `llm` CLI tool to provide help in a terminal. It is provided context from your current terminal session to give more relevant help:

- The `!!` and `!$` history expansions are supported to provide context from the last command run and its success/failure.
- If you run your sessions within `tmux` the current screen content is also provided as context.

Get help:

```sh
# You make a subtle error in a find command, looking for dates in filenames:
> find . -name [0-9]*-[0-9]*-[0-9]*.txt
zsh: no matches found: [0-9]*-[0-9]*-[0-9]*.txt

# You ask for help:
> llmhelp
find . -name "[0-9]*-[0-9]*-[0-9]*.txt"

# llmhelp provides a suggestion, and copies it to your clipboard.
# If you like the result just paste it in and run it.
```

Ask for an explanation:

```sh
> find . -name "[0-9]*-[0-9]*-[0-9]*.txt"
...
...

llmhelp explain how these regexes work

    The provided text shows attempts to use the `find` command with regular expressions to locate files.  `find`
  itself doesn't directly use regular expressions; it uses shell globbing patterns.  The patterns `[0-9]*-[0-9]*-[0-
  9]*.txt` attempts to match filenames containing numbers, hyphens, and the extension `.txt`.  The `*` is a wildcard
  matching zero or more occurrences of the preceding character.  To illustrate:

    * `[0-9]*`: Matches zero or more digits.
    * `-`: Matches a literal hyphen.
    * `[0-9]*-[0-9]*-[0-9]*.txt`:  Matches filenames like `123-456-789.txt`, `1-2-3.txt`, or even `-.txt` (as it allows zero
  digits).

...
```

You can read my [blog entry](https://www.pinedesk.biz/dailytoon/2025-08-11-2025-08-17/#making-llm-helpers-for-the-cli) for more information about how can help you on the CLI.

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
