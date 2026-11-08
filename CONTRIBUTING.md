# Contributing a plugin

Thanks for adding to goatty! A good plugin makes a tool approachable: someone who has never used it should understand every setting from its label and help text.

## 1. Build it

Use the [template](https://github.com/goatty-dev/goatty-plugin-template): it has a complete, commented `plugin.toml`, a validation workflow, and a Claude Code skill that walks through creating a plugin. The format is documented in goatty's [docs/plugins.md](https://github.com/goatty-dev/goatty/blob/main/docs/plugins.md).

```sh
cargo install --git https://github.com/goatty-dev/goatty --locked goatty-plugin
goatty-plugin new mytool          # or start from the template
goatty-plugin hash <release-url>  # sha256, size, and the executables in the archive
goatty-plugin validate .
goatty-plugin render . --set some_setting=value   # what goatty would generate
goatty-plugin check-downloads .   # every asset downloads and matches
goattyd plugin install --path .   # try it in goatty (marked "local, unverified")
```

## 2. Rules

- **Pinned releases only.** Official release assets from the tool's own project, `https://` only, with the sha256 you computed from the download and checked against upstream's checksums (GitHub shows a `sha256:` digest per asset). Releases at least two weeks old.
- **Static builds when they exist** (`-musl` on Linux), so the program works on any distribution.
- **Shell code is the exception.** Prefer aliases, environment variables and config files: goatty generates and quotes those itself. A `zsh.init` file is for tools that need it (like `zoxide init`). It must not download anything, run at every prompt without need, write outside `~/.cache/goatty`, or print output at startup.
- **No `curl | sh`, no `sudo`, no edits to dotfiles.** goatty never touches files outside its own directories, and neither may a plugin.
- **Explain every setting** in plain words (`help`), and every powerful permission in `[permissions]`.
- **Defaults are opinionated but safe:** a fresh install should feel good without changing anything, and shouldn't surprise someone who knows the tool.
- **New versions are new directories** (`plugins/<id>/1.1.0/`). Don't edit published ones.

## 3. Open a pull request

Add `plugins/<id>/<version>/` and nothing else (don't touch `index.json` or its signature; a maintainer regenerates them). CI validates your plugin and downloads its assets. Fill in the pull request template.
