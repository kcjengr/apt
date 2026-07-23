# kcjengr apt repository

Debian package repository for [qtpyvcp](https://github.com/kcjengr/qtpyvcp),
[probe_basic](https://github.com/kcjengr/probe_basic),
[turbonc](https://github.com/kcjengr/turbonc), and
[monokrom](https://github.com/kcjengr/monokrom), served via GitHub Pages at
`repository.qtpyvcp.com`.

The served apt tree lives under `apt/` (`apt/dists/`, `apt/pool/`) — **not**
the repo root — because every existing install's `sources.list` points at
`https://repository.qtpyvcp.com/apt`, so apt fetches
`.../apt/dists/<suite>/...`. It's updated automatically by the
`release-stable.yml`/`release-dev.yml` workflows in the source repos, which
build `.deb` packages and push the results here.

Suites:

| dists suite    | pool dir        | codename | notes                          |
|----------------|------------------|----------|---------------------------------|
| `bookworm`     | `bookworm`       | bookworm | pyqt5, stable releases          |
| `stable`       | `bookworm`       | bookworm | alias, kept for older docs/installs |
| `bookworm-dev` | `bookworm-dev`   | bookworm | pyqt5, continuous dev builds    |
| `develop`      | `bookworm-dev`   | bookworm | alias, kept for older docs/installs |
| `trixie`       | `trixie`         | trixie   | pyside6, stable releases        |
| `trixie-dev`   | `trixie-dev`     | trixie   | pyside6, continuous dev builds  |

Release file `Origin`/`Label`/`Suite`/`Codename` are all set to match the
suite name exactly (`Origin`/`Label` prefixed `apt `), mirroring what the
live repo's aptly-generated Release files currently use -- this avoids
apt's "repository changed its Origin/Label value" prompt on existing
users' first update after cutover.

`scripts/publish-suite.sh <dists-suite> <pool-suite> <arch...>` scans a pool
directory and (re)generates the signed `Packages`/`Release`/`InRelease` for
one suite. Requires `GPG_KEY_ID` set in the environment and the corresponding
private key imported into the local GPG keyring.

## Backported packages

Some runtime dependencies declared by qtpyvcp/probe_basic aren't packaged for
bookworm in Debian proper (only trixie has them) — these are backported here
from Debian's own trixie source packages, unmodified, and published in the
`bookworm`/`bookworm-dev` pool alongside qtpyvcp/probe_basic:

- `python3-hiyapyco` (0.7.0-2) — built from Debian trixie's `python-hiyapyco`
  source package against bookworm; builds unmodified, arch `all`.
