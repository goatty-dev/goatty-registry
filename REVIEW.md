# Review checklist

Every plugin version is reviewed before it's signed into the index. The signature tells users "the goatty maintainers looked at this"; this list is what that means.

## Source and downloads

- [ ] Each asset URL is an official release of the tool's own project (not a fork, mirror or personal account).
- [ ] The sha256 matches upstream's published checksum (GitHub's per-asset `sha256:` digest or the project's checksums file), and CI's `check-downloads` passed.
- [ ] The release is at least two weeks old and not a pre-release.
- [ ] Static (musl) builds where upstream offers them; anything else is noted in a comment.
- [ ] `bin` lists only the tool's own executables; none of them shadows a common system command unless that's the point of the tool.

## What it does to the shell

- [ ] Aliases that replace existing commands (`ls`, `cat`, `cd`) are behind a setting, and the help text says so.
- [ ] Environment variables are the tool's own (no `PATH`, `LD_*`, credentials, proxies).
- [ ] `zsh.init`, if any: read every line. No network access, no downloads, no `eval` of anything but the tool's own init output, no writes outside `~/.cache/goatty`, no output at startup, nothing slow at every prompt.
- [ ] The `[permissions]` reasons are accurate and understandable.

## Settings

- [ ] Each setting has a label and help text a newcomer understands.
- [ ] Choices are preferred over free text; free text never ends up in shell code (goatty quotes values, but the tool still has to accept them).
- [ ] Defaults are sensible; `goatty-plugin render` output was read.

## Publish

- [ ] `scripts/publish.sh <key>` (validate, check downloads, rebuild, sign), commit, push.
