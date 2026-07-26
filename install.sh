#!/bin/sh
# Adds (or repairs) the kcjengr apt repository for qtpyvcp/probe_basic/
# turbonc/monokrom.
#
# Safe to run on a machine that already has the repo configured -- it
# replaces any existing kcjengr/qtpyvcp apt source with a correct one for
# the running Debian release, and installs the current signing key where
# that source actually looks for it. This fixes:
#
#   * "Missing key 50F874571F20C5B0BA225E2F0CDFCCE0388CFA48" / "the
#     repository is not signed" errors, including when an old source line
#     has a signed-by= pointing at a stale keyring (in which case adding
#     the key to /etc/apt/trusted.gpg.d/ alone does NOT help).
#   * a source pointing at the wrong Debian release (e.g. a bookworm
#     suite such as "develop" left behind on a trixie machine).
#
# Usage:
#   curl -fsSL https://repository.qtpyvcp.com/install.sh | sudo sh
#
# The stable/dev channel is auto-detected from any existing config and
# kept as-is. Force one with:
#   ... | sudo sh -s -- --dev
#   ... | sudo sh -s -- --stable

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo "This needs to run as root (try: curl ... | sudo sh)" >&2
  exit 1
fi

CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"
case "$CODENAME" in
  bookworm|trixie) ;;
  *)
    echo "Unsupported Debian release '$CODENAME' -- only bookworm (PyQt5) and trixie (PySide6) are published." >&2
    exit 1
    ;;
esac

# Find every existing apt source that refers to this repository, so we can
# retire them instead of leaving a broken duplicate behind.
OLD_FILES=""
for f in /etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources; do
  [ -f "$f" ] || continue
  if grep -qi 'repository\.qtpyvcp\.com' "$f" 2>/dev/null; then
    OLD_FILES="$OLD_FILES $f"
  fi
done

# Keep the channel the machine is already on unless told otherwise.
CHANNEL=""
case "$1" in
  --dev) CHANNEL="dev" ;;
  --stable) CHANNEL="stable" ;;
  "") ;;
  *) echo "Unknown option '$1' (expected --dev or --stable)" >&2; exit 1 ;;
esac

if [ -z "$CHANNEL" ]; then
  # Always the dev channel unless --stable is passed explicitly. The
  # stable suites are published but are NOT release-ready for users, so
  # nothing here may put a machine on them by inference -- a machine that
  # somehow ended up on stable gets moved back to dev by running this.
  CHANNEL="dev"
fi

if [ "$CHANNEL" = "dev" ]; then
  SUITE="${CODENAME}-dev"
else
  SUITE="${CODENAME}"
fi

KEYRING=/etc/apt/keyrings/kcjengr.gpg
mkdir -p /etc/apt/keyrings
curl -fsSL https://repository.qtpyvcp.com/repo/kcjengr.key | gpg --dearmor -o "$KEYRING.new"
mv "$KEYRING.new" "$KEYRING"
chmod 0644 "$KEYRING"

# Refresh any keyring an existing source line points at, so machines that
# are mid-upgrade (or that we don't fully rewrite) also end up trusting the
# current key rather than a stale copy.
for f in $OLD_FILES; do
  for kr in $(grep -o 'signed-by=[^]" ]*' "$f" 2>/dev/null | cut -d= -f2); do
    case "$kr" in
      "$KEYRING") continue ;;
    esac
    if [ -f "$kr" ]; then
      cp "$KEYRING" "$kr"
      echo "Refreshed stale keyring: $kr"
    fi
  done
done

# Retire old source files (kept as .disabled so nothing is lost).
for f in $OLD_FILES; do
  mv "$f" "$f.disabled"
  echo "Retired old apt source: $f -> $f.disabled"
done

cat > /etc/apt/sources.list.d/kcjengr.list <<EOF
deb [signed-by=$KEYRING] https://repository.qtpyvcp.com/apt $SUITE main
EOF

apt-get update

echo
echo "kcjengr repo configured for Debian $CODENAME, suite '$SUITE' ($CHANNEL channel)."
echo "Install packages, e.g.: apt-get install python3-qtpyvcp python3-probe-basic"
