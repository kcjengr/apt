#!/usr/bin/env bash
set -euo pipefail

# Generates a Release file for dists/<suite> via apt-ftparchive.
#
# NOTE: this is a best-effort reconstruction. The buildbot's original
# generate-<suite>.sh only ever lived on the buildbot box itself
# (/home/buildbot/debian/generate-*.sh) and wasn't available to port
# from directly -- if exact Origin/Label parity with the existing repo
# matters, pull the original script off that box and diff it against
# this one before relying on it for the real cutover.
#
# Usage: generate-release.sh <suite> <arch...>

if [[ $# -lt 2 ]]; then
    echo "usage: $0 <suite> <arch...>" >&2
    exit 1
fi

SUITE="$1"
shift
ARCHES=("$@")

case "${SUITE}" in
    bookworm|stable|bookworm-dev|develop) CODENAME="bookworm" ;;
    trixie|trixie-dev)                    CODENAME="trixie" ;;
    *) echo "unknown suite: ${SUITE}" >&2; exit 1 ;;
esac

DISTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../dists/${SUITE}" && pwd)"

apt-ftparchive \
    -o "APT::FTPArchive::Release::Origin=kcjengr" \
    -o "APT::FTPArchive::Release::Label=QtPyVCP" \
    -o "APT::FTPArchive::Release::Suite=${SUITE}" \
    -o "APT::FTPArchive::Release::Codename=${CODENAME}" \
    -o "APT::FTPArchive::Release::Architectures=${ARCHES[*]}" \
    -o "APT::FTPArchive::Release::Components=main" \
    -o "APT::FTPArchive::Release::Description=QtPyVCP/Probe Basic apt repository" \
    release "${DISTS_DIR}"
