#!/bin/sh
# Adds the kcjengr apt repository (qtpyvcp/probe_basic/turbonc/monokrom)
# for the running machine's actual Debian release, so the wrong suite
# (e.g. bookworm packages on a trixie machine) can't get added by hand
# by copy-pasting the wrong line.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/kcjengr/apt/main/install.sh | sudo sh
#   curl -fsSL https://raw.githubusercontent.com/kcjengr/apt/main/install.sh | sudo sh -s -- --dev

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo "This needs to run as root (try: curl ... | sudo sh)" >&2
  exit 1
fi

SUITE_TYPE="stable"
if [ "$1" = "--dev" ]; then
  SUITE_TYPE="dev"
fi

CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"

case "$CODENAME" in
  bookworm)
    ;;
  trixie)
    ;;
  *)
    echo "Unsupported Debian release '$CODENAME' -- only bookworm (PyQt5) and trixie (PySide6) are published." >&2
    exit 1
    ;;
esac

if [ "$SUITE_TYPE" = "dev" ]; then
  SUITE="${CODENAME}-dev"
else
  SUITE="${CODENAME}"
fi

KEYRING=/etc/apt/keyrings/kcjengr.gpg
mkdir -p /etc/apt/keyrings
curl -fsSL https://repository.qtpyvcp.com/repo/kcjengr.key | gpg --dearmor -o "$KEYRING"

cat > /etc/apt/sources.list.d/kcjengr.list <<EOF
deb [signed-by=$KEYRING] https://repository.qtpyvcp.com/apt $SUITE main
EOF

apt-get update

echo
echo "Added the kcjengr repo for Debian $CODENAME, suite '$SUITE'."
echo "Install packages, e.g.: apt-get install python3-qtpyvcp python3-probe-basic"
