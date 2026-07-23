#!/usr/bin/env bash
set -euo pipefail

# Scan a pool directory and (re)generate the signed Packages/Release/InRelease
# for one dists/<suite> tree. Replaces the buildbot's do_apt_*.sh scripts,
# which were near-identical copies of this same logic per suite.
#
# Usage: publish-suite.sh <dists-suite> <pool-suite> <arch...>
#
# dists-suite and pool-suite differ only for the back-compat suite-name
# aliases (stable -> bookworm pool, develop -> bookworm-dev pool) that
# existing installs still reference.

if [[ $# -lt 3 ]]; then
    echo "usage: $0 <dists-suite> <pool-suite> <arch...>" >&2
    exit 1
fi

DISTS_SUITE="$1"
POOL_SUITE="$2"
shift 2
ARCHES=("$@")

: "${GPG_KEY_ID:?GPG_KEY_ID must be set}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DISTS_DIR="${REPO_ROOT}/apt/dists/${DISTS_SUITE}"
POOL_DIR="${REPO_ROOT}/apt/pool/main/${POOL_SUITE}"

cd "${REPO_ROOT}/apt"

for ARCH in "${ARCHES[@]}"; do
    mkdir -p "${DISTS_DIR}/main/binary-${ARCH}"
    dpkg-scanpackages --arch "${ARCH}" "pool/main/${POOL_SUITE}" \
        > "${DISTS_DIR}/main/binary-${ARCH}/Packages"
    gzip -9 -c "${DISTS_DIR}/main/binary-${ARCH}/Packages" \
        > "${DISTS_DIR}/main/binary-${ARCH}/Packages.gz"
done

"${REPO_ROOT}/scripts/generate-release.sh" "${DISTS_SUITE}" "${ARCHES[@]}" \
    > "${DISTS_DIR}/Release"

gpg --batch --yes --default-key "${GPG_KEY_ID}" -abs \
    -o "${DISTS_DIR}/Release.gpg" "${DISTS_DIR}/Release"
gpg --batch --yes --default-key "${GPG_KEY_ID}" -abs --clearsign \
    -o "${DISTS_DIR}/InRelease" "${DISTS_DIR}/Release"
