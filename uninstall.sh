#!/bin/sh
# Completely removes the kcjengr apt repository configuration and packages
# (qtpyvcp / probe_basic / turbonc / monokrom) so the machine can be set up
# again cleanly with install.sh.
#
# Removes:
#   * the installed packages (apt purge)
#   * every apt source referring to repository.qtpyvcp.com
#   * every apt keyring holding this repo's signing key, including stale
#     ones left by older install instructions and apt-key-era entries
#
# Does NOT touch:
#   * any other apt repository or key on the machine
#   * your LinuxCNC configs in ~/linuxcnc (your machine configs live there)
#
# Usage:
#   curl -fsSL https://repository.qtpyvcp.com/uninstall.sh | sudo sh
#
# Then reinstall with:
#   curl -fsSL https://repository.qtpyvcp.com/install.sh | sudo sh

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo "This needs to run as root (try: curl ... | sudo sh)" >&2
  exit 1
fi

# Long key ID of this repository's signing key, used to identify which
# keyrings belong to us so unrelated repositories are left alone.
KEY_LONG_ID="0CDFCCE0388CFA48"
# Older, never-actually-published key some configs may reference.
KEY_LEGACY_ID="2DEC041F290DF85A"

echo "== Removing packages =="
PKGS="python3-qtpyvcp python3-qtpyvcp-dbgsym python3-probe-basic python3-turbonc python3-monokrom"
INSTALLED=""
for p in $PKGS; do
  if dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q 'install ok installed\|deinstall ok config-files'; then
    INSTALLED="$INSTALLED $p"
  fi
done
if [ -n "$INSTALLED" ]; then
  # shellcheck disable=SC2086
  DEBIAN_FRONTEND=noninteractive apt-get purge -y $INSTALLED
else
  echo "  (none installed)"
fi

echo "== Removing apt sources =="
FOUND_SRC=0
for f in /etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources \
         /etc/apt/sources.list.d/*.list.disabled /etc/apt/sources.list.d/*.sources.disabled; do
  [ -f "$f" ] || continue
  grep -qi 'repository\.qtpyvcp\.com' "$f" 2>/dev/null || continue
  FOUND_SRC=1
  case "$f" in
    /etc/apt/sources.list)
      # Never delete the main sources.list -- just strip our lines from it.
      sed -i.qtpyvcp-bak '/repository\.qtpyvcp\.com/d' "$f"
      echo "  stripped our entries from $f (backup: $f.qtpyvcp-bak)"
      ;;
    *)
      rm -f "$f"
      echo "  removed $f"
      ;;
  esac
done
[ "$FOUND_SRC" -eq 0 ] && echo "  (none found)"

echo "== Removing keyrings =="
FOUND_KEY=0
for kr in /etc/apt/keyrings/* /etc/apt/trusted.gpg.d/* /usr/share/keyrings/*; do
  [ -f "$kr" ] || continue
  MATCH=""
  # Remove a keyring if it actually contains our key...
  if gpg --show-keys --with-colons "$kr" 2>/dev/null \
       | grep -Eq "$KEY_LONG_ID|$KEY_LEGACY_ID"; then
    MATCH="contains our signing key"
  else
    # ...or if it is unmistakably one of ours by name, which catches stale
    # keyrings left by old instructions that hold some other/expired key.
    case "$(basename "$kr")" in
      *qtpyvcp*|*kcjengr*) MATCH="named for this repository" ;;
    esac
  fi
  if [ -n "$MATCH" ]; then
    rm -f "$kr"
    echo "  removed $kr ($MATCH)"
    FOUND_KEY=1
  fi
done

# apt-key era: keys added with "apt-key add" land in this legacy keyring.
if [ -f /etc/apt/trusted.gpg ] && command -v gpg >/dev/null 2>&1; then
  for kid in "$KEY_LONG_ID" "$KEY_LEGACY_ID"; do
    if gpg --no-default-keyring --keyring /etc/apt/trusted.gpg --list-keys "$kid" >/dev/null 2>&1; then
      gpg --no-default-keyring --keyring /etc/apt/trusted.gpg \
          --batch --yes --delete-key "$kid" >/dev/null 2>&1 || true
      echo "  removed $kid from legacy /etc/apt/trusted.gpg"
      FOUND_KEY=1
    fi
  done
fi
[ "$FOUND_KEY" -eq 0 ] && echo "  (none found)"

echo "== Refreshing apt =="
apt-get update

cat <<'EOF'

Done -- this machine no longer has the kcjengr repository configured.
Your LinuxCNC configs in ~/linuxcnc were not touched.

To install again cleanly:
  curl -fsSL https://repository.qtpyvcp.com/install.sh | sudo sh
EOF
