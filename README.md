# zz

Translate natural-language instructions into a single Bash command via LLM backends.

## Synopsis

```bash
zz [--backend BACKEND] [--model MODEL] [-h|--help] INSTRUCTION
```

## Backends

| Backend  | Description                                                                 |
|----------|-----------------------------------------------------------------------------|
| `openai` | Use the OpenAI Chat Completions API via `curl` and `jq`. Requires `OPENAI_API_KEY`. |
| `ollama` | Use the local `ollama` CLI to run a downloaded model. Requires `ollama` CLI and a pulled model. |
| `llm`    | Use the Datasette `llm` CLI with a configured plugin. Requires `llm` CLI.       |

## Options

- `--backend BACKEND`  Select one of `openai` (default), `ollama`, or `llm`.
- `--model MODEL`      Model name or identifier to pass to the backend driver (default: `gpt-4o`).
- `-h`, `--help`       Show usage information and exit.

## Environment Variables

- `OPENAI_API_KEY`  API key used by the `openai` backend via the OpenAI API.
- `ZZ_BACKEND`      If set, provides the default for the `--backend` option.

## Installation

Make sure the script is executable and on your `PATH`:

```bash
chmod +x zz.sh
cp zz.sh ~/bin/zz    # or any directory in your PATH
```

(Optional) install the manpage:

```bash
sudo install -D -m644 man/zz.1 /usr/local/share/man/man1/zz.1
```

## Examples

```bash
zz "list all python files in the current directory"
zz --model gpt-4o "list all .md files"
zz --backend openai --model gpt-4o "show me the current directory"
zz --backend ollama --model phi3 "print the working directory"
zz --backend llm "show me the first 5 lines of README.md"
```

## Viewing the Manpage

View it without installing:

```bash
nroff -man man/zz.1 | less -R
```

Or temporarily extend your `MANPATH`:

```bash
export MANPATH="$(pwd)/man:$MANPATH"
man zz
```

## See Also

`curl(1)`, `jq(1)`, `ollama(1)`, `llm(1)`

## Author

Written by Joseph Ian Walker.

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.