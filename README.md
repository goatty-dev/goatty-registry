# goatty plugin registry

The official registry of [goatty](https://github.com/goatty-dev/goatty) plugins. goatty reads it to offer plugins in **Settings → Plugins** and in `goattyd plugin search`.

A plugin is a reviewed, declarative `plugin.toml`: which program to download (pinned by sha256), which settings goatty shows for it (with explanations), and how those settings reach the tool (aliases, environment variables, a generated config file, or a small reviewed zsh file). goatty installs into its own directory, never system-wide, and never with sudo.

| Plugin | What it does | Installs | Shell code |
|---|---|---|---|
| [eza](plugins/eza) | A modern `ls`: colors, icons, git status, tree view | eza 0.23.5 | – |
| [zoxide](plugins/zoxide) | Jump to directories you use often (`z proj`) | zoxide 0.10.0 | `zoxide init zsh` |
| [bat](plugins/bat) | `cat` with syntax highlighting, line numbers, git changes | bat 0.26.1 | – |
| [docker](plugins/docker) | Tab completion and short aliases for your Docker CLI | – (uses yours) | cached `docker completion zsh` |

## Layout

```
registry.toml                 name, trusted signing keys, yanked versions
plugins/<id>/<version>/       one plugin version: plugin.toml (+ zsh/ files)
index.json                    generated: every plugin version and the sha256 of each of its files
index.json.sig                Ed25519 signature over index.json, made offline by a maintainer
```

Published versions are never edited. A change is a new version directory.

## How goatty trusts this

1. goatty ships the registry's public key (`registry.toml` → `keys`).
2. It downloads this repository's `main` branch as a tarball and checks `index.json.sig` against that key. A bad or missing signature, or an index older than one it has seen (`sequence`), is refused.
3. `index.json` pins every file of every plugin by sha256. Files not in the signed index are ignored.
4. Each `plugin.toml` pins every download by sha256. goatty checks it before unpacking anything.
5. Before installing, goatty shows the user what the plugin will do: downloads, programs on `PATH`, aliases, environment variables, and the full text of any shell code. The user approves that exact plan; if anything changes in between, the install is refused.

A signature proves where a plugin came from and that nobody changed it. It doesn't make a program harmless: plugins run with the user's permissions. That's why every plugin is reviewed ([REVIEW.md](REVIEW.md)) and why goatty asks first.

## Adding a plugin

Start from the [plugin template](https://github.com/goatty-dev/goatty-plugin-template), then follow [CONTRIBUTING.md](CONTRIBUTING.md). In short: put your plugin in `plugins/<id>/<version>/`, run `goatty-plugin validate` and `goatty-plugin check-downloads`, open a pull request. A maintainer reviews it, rebuilds and signs the index.

## Maintainers: publishing

```sh
cargo install --git https://github.com/goatty-dev/goatty --locked goatty-plugin
scripts/publish.sh ~/.local/share/goatty-registry-keys/official-1.key
git commit -am "Publish index #N" && git push
```

`publish.sh` validates every plugin, re-downloads every asset to check its checksum, rebuilds `index.json` (the `sequence` goes up when plugins changed), and signs it. The secret key stays offline; CI only verifies.

**Key rotation:** add the new public key to `registry.toml` and to goatty (`OFFICIAL_KEYS`), release goatty, sign with the new key once enough users have that release, then remove the old key from both.

## License

The manifests and shell files in this repository are MIT OR Apache-2.0, like goatty. The tools they install keep their own licenses (each manifest's `license`).
