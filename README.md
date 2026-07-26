# kcjengr apt repository

## Build status

| Project | bookworm (stable) | bookworm-dev | trixie (stable) | trixie-dev |
|---|---|---|---|---|
| [qtpyvcp](https://github.com/kcjengr/qtpyvcp) | [![](https://github.com/kcjengr/qtpyvcp/actions/workflows/release-stable-bookworm.yml/badge.svg)](https://github.com/kcjengr/qtpyvcp/actions/workflows/release-stable-bookworm.yml) | [![](https://github.com/kcjengr/qtpyvcp/actions/workflows/release-dev.yml/badge.svg?branch=main)](https://github.com/kcjengr/qtpyvcp/actions/workflows/release-dev.yml?query=branch%3Amain) | [![](https://github.com/kcjengr/qtpyvcp/actions/workflows/release-stable-trixie.yml/badge.svg)](https://github.com/kcjengr/qtpyvcp/actions/workflows/release-stable-trixie.yml) | [![](https://github.com/kcjengr/qtpyvcp/actions/workflows/release-dev.yml/badge.svg?branch=pyside6)](https://github.com/kcjengr/qtpyvcp/actions/workflows/release-dev.yml?query=branch%3Apyside6) |
| [probe_basic](https://github.com/kcjengr/probe_basic) | [![](https://github.com/kcjengr/probe_basic/actions/workflows/release-stable-bookworm.yml/badge.svg)](https://github.com/kcjengr/probe_basic/actions/workflows/release-stable-bookworm.yml) | [![](https://github.com/kcjengr/probe_basic/actions/workflows/release-dev.yml/badge.svg?branch=main)](https://github.com/kcjengr/probe_basic/actions/workflows/release-dev.yml?query=branch%3Amain) | [![](https://github.com/kcjengr/probe_basic/actions/workflows/release-stable-trixie.yml/badge.svg)](https://github.com/kcjengr/probe_basic/actions/workflows/release-stable-trixie.yml) | [![](https://github.com/kcjengr/probe_basic/actions/workflows/release-dev.yml/badge.svg?branch=pyside6)](https://github.com/kcjengr/probe_basic/actions/workflows/release-dev.yml?query=branch%3Apyside6) |
| [turbonc](https://github.com/kcjengr/turbonc) | [![](https://github.com/kcjengr/turbonc/actions/workflows/release-stable-bookworm.yml/badge.svg)](https://github.com/kcjengr/turbonc/actions/workflows/release-stable-bookworm.yml) | [![](https://github.com/kcjengr/turbonc/actions/workflows/release-dev.yml/badge.svg?branch=main)](https://github.com/kcjengr/turbonc/actions/workflows/release-dev.yml?query=branch%3Amain) | [![](https://github.com/kcjengr/turbonc/actions/workflows/release-stable-trixie.yml/badge.svg)](https://github.com/kcjengr/turbonc/actions/workflows/release-stable-trixie.yml) | [![](https://github.com/kcjengr/turbonc/actions/workflows/release-dev.yml/badge.svg?branch=pyside6)](https://github.com/kcjengr/turbonc/actions/workflows/release-dev.yml?query=branch%3Apyside6) |
| [monokrom](https://github.com/kcjengr/monokrom) | [![](https://github.com/kcjengr/monokrom/actions/workflows/release-stable-bookworm.yml/badge.svg)](https://github.com/kcjengr/monokrom/actions/workflows/release-stable-bookworm.yml) | [![](https://github.com/kcjengr/monokrom/actions/workflows/release-dev.yml/badge.svg?branch=main)](https://github.com/kcjengr/monokrom/actions/workflows/release-dev.yml?query=branch%3Amain) | [![](https://github.com/kcjengr/monokrom/actions/workflows/release-stable-trixie.yml/badge.svg)](https://github.com/kcjengr/monokrom/actions/workflows/release-stable-trixie.yml) | [![](https://github.com/kcjengr/monokrom/actions/workflows/release-dev.yml/badge.svg?branch=pyside6)](https://github.com/kcjengr/monokrom/actions/workflows/release-dev.yml?query=branch%3Apyside6) |

Each badge is live (auto-updates) and links straight to that workflow's run
history.

**[Live status page →](https://repository.qtpyvcp.com/status.html)** — shows
**yellow while a build is running**, green when it passed and red when it
failed. The badges above cannot do that: GitHub only regenerates a badge once
a run *finishes*, so a build in progress still shows the previous result. The
status page reads the GitHub API directly and refreshes on its own.

Debian package repository for [qtpyvcp](https://github.com/kcjengr/qtpyvcp),
[probe_basic](https://github.com/kcjengr/probe_basic),
[turbonc](https://github.com/kcjengr/turbonc), and
[monokrom](https://github.com/kcjengr/monokrom), served via GitHub Pages at
`repository.qtpyvcp.com`.

## Installing (and fixing a broken install)

```sh
curl -fsSL https://repository.qtpyvcp.com/install.sh | sudo sh
```

Run this to set the repo up for the first time **or** to repair an existing
machine. Then install packages as usual, e.g.
`apt-get install python3-qtpyvcp python3-probe-basic`.

It detects your Debian release (`bookworm` or `trixie`) from
`/etc/os-release` and configures the matching suite, so the wrong suite
can't be added by hand — e.g. a `bookworm` suite such as `develop` left on
a `trixie` machine, which apt will happily use and which can pull in
ABI-incompatible packages.

This installs the **develop** channel, which is the channel to use. The
`stable` suites exist and are built, but are not release-ready — don't
point users at them.

### "Missing key ... / the repository is not signed"

If `apt update` reports:

```
Missing key 50F874571F20C5B0BA225E2F0CDFCCE0388CFA48, which is needed to verify signature.
E: The repository '...' is not signed.
```

run the command above — it installs the current signing key and repairs the
source line. Any previous apt source for this repository is retired to a
`.disabled` file rather than deleted.

Note that just adding the key to `/etc/apt/trusted.gpg.d/` is **not** always
enough: if the old source line carries a `signed-by=` pointing at a stale
keyring, that keyring takes precedence and the error persists. The script
handles that case by refreshing the keyring the source actually references.

The served apt tree lives under `apt/` (`apt/dists/`, `apt/pool/`) — **not**
the repo root — because every existing install's `sources.list` points at
`https://repository.qtpyvcp.com/apt`, so apt fetches
`.../apt/dists/<suite>/...`. It's updated automatically by the
`release-stable-{bookworm,trixie}.yml`/`release-dev.yml` workflows in the source repos, which
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
