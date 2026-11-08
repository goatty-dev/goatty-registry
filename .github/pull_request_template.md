## Plugin

- Tool: <!-- name and homepage -->
- Plugin id and version: <!-- plugins/<id>/<version>/ -->
- New plugin / new version of an existing one:

## Checklist

- [ ] Assets are official releases, at least two weeks old; sha256 checked against upstream's checksums
- [ ] `goatty-plugin validate` and `goatty-plugin check-downloads` pass
- [ ] Tried it with `goattyd plugin install --path plugins/<id>/<version>`
- [ ] Every setting has help text a newcomer understands
- [ ] Shell code (if any) is minimal and explained in `[permissions]`
- [ ] I didn't touch `index.json` / `index.json.sig`
