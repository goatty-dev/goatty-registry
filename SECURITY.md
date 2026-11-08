# Security

If a plugin in this registry does something it shouldn't, or you found a way around goatty's checks (signature, checksums, install plan), please report it privately through GitHub's security advisories for [goatty-dev/goatty](https://github.com/goatty-dev/goatty/security/advisories/new) rather than an issue.

A compromised plugin version is yanked (`registry.toml` → `yanked`) and a fixed index is signed right away; goatty stops offering yanked versions on its next registry refresh.

Signing keys (Ed25519): see `registry.toml`. They're generated with `goatty-plugin keygen` and kept offline by the maintainers.
