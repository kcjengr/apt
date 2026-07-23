# kcjengr apt repository

Debian package repository for [qtpyvcp](https://github.com/kcjengr/qtpyvcp) and
[probe_basic](https://github.com/kcjengr/probe_basic), served via GitHub Pages
at `repository.qtpyvcp.com`.

This repo's root *is* the served apt tree (`dists/`, `pool/`) — it's updated
automatically by the `release-stable.yml`/`release-dev.yml` workflows in the
source repos, which build `.deb` packages and push the results here.

Suites:

| dists suite    | pool dir        | codename | notes                          |
|----------------|------------------|----------|---------------------------------|
| `bookworm`     | `bookworm`       | bookworm | pyqt5, stable releases          |
| `stable`       | `bookworm`       | bookworm | alias, kept for older docs/installs |
| `bookworm-dev` | `bookworm-dev`   | bookworm | pyqt5, continuous dev builds    |
| `develop`      | `bookworm-dev`   | bookworm | alias, kept for older docs/installs |
| `trixie`       | `trixie`         | trixie   | pyside6, stable releases        |
| `trixie-dev`   | `trixie-dev`     | trixie   | pyside6, continuous dev builds  |

`scripts/publish-suite.sh <dists-suite> <pool-suite> <arch...>` scans a pool
directory and (re)generates the signed `Packages`/`Release`/`InRelease` for
one suite. Requires `GPG_KEY_ID` set in the environment and the corresponding
private key imported into the local GPG keyring.
