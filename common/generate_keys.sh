#!/bin/bash
#
# Generate OpenPGP signing keys for Pulp test fixtures using Sequoia (sq).
#
# Generates v4 (RFC 4880) and v6 (RFC 9580) keys across multiple algorithm
# types, including post-quantum (ML-DSA) hybrid keys. Also generates keyrings
# containing multiple certificates for testing multi-key scenarios.
#
# Prerequisites:
#   - sq (Sequoia PGP CLI) with support for --profile rfc9580 and ML-DSA
#     cipher suites. Tested with sq 1.x (https://sequoia-pgp.org/).
#
# Usage:
#   cd pulp-fixtures/common && ./generate_keys.sh
#
# The existing GPG-KEY-* and GPG-PRIVATE-KEY-* files are NOT touched.
# New keys are written into signing_keys/.

set -euo pipefail

OUTDIR="$(cd "$(dirname "$0")" && pwd)/signing_keys"

mkdir -p "$OUTDIR"

REVDIR=$(mktemp -d)
trap 'rm -rf "$REVDIR"' EXIT

generate_key() {
    local profile="$1"   # rfc4880 | rfc9580
    local suite="$2"     # cipher suite
    local name="$3"      # key name (used in uid and filenames)

    sq key generate \
        --own-key \
        --name "$name" \
        --email "${name}@example.com" \
        --cipher-suite "$suite" \
        --profile "$profile" \
        --expiration=never \
        --can-sign \
        --cannot-authenticate \
        --cannot-encrypt \
        --without-password \
        --output "$OUTDIR/${name}.secret" \
        --rev-cert "$REVDIR/${name}.rev"

    sq keyring filter --experimental --to-cert --overwrite \
        "$OUTDIR/${name}.secret" \
        --output "$OUTDIR/${name}.asc"

    echo "  $name ($suite, $profile)"
}

echo "Generating v4 (RFC 4880) keys..."
generate_key rfc4880 rsa2k   pulp-testkey-v4-rsa2k
generate_key rfc4880 rsa4k   pulp-testkey-v4-rsa4k
generate_key rfc4880 cv25519 pulp-testkey-v4-ed25519

echo "Generating v6 (RFC 9580) keys..."
generate_key rfc9580 rsa4k           pulp-testkey-v6-rsa4k
generate_key rfc9580 cv25519         pulp-testkey-v6-ed25519
generate_key rfc9580 mldsa65-ed25519 pulp-testkey-v6-mldsa65-ed25519
generate_key rfc9580 mldsa87-ed448   pulp-testkey-v6-mldsa87-ed448

echo "Generating keyrings..."

# v4 keyring
sq keyring merge --overwrite \
    "$OUTDIR/pulp-testkey-v4-rsa2k.asc" \
    "$OUTDIR/pulp-testkey-v4-rsa4k.asc" \
    "$OUTDIR/pulp-testkey-v4-ed25519.asc" \
    --output "$OUTDIR/pulp-testkey-v4-keyring.asc"
sq keyring merge --overwrite \
    "$OUTDIR/pulp-testkey-v4-rsa2k.secret" \
    "$OUTDIR/pulp-testkey-v4-rsa4k.secret" \
    "$OUTDIR/pulp-testkey-v4-ed25519.secret" \
    --output "$OUTDIR/pulp-testkey-v4-keyring.secret"

# v6 keyring
sq keyring merge --overwrite \
    "$OUTDIR/pulp-testkey-v6-rsa4k.asc" \
    "$OUTDIR/pulp-testkey-v6-ed25519.asc" \
    "$OUTDIR/pulp-testkey-v6-mldsa65-ed25519.asc" \
    "$OUTDIR/pulp-testkey-v6-mldsa87-ed448.asc" \
    --output "$OUTDIR/pulp-testkey-v6-keyring.asc"
sq keyring merge --overwrite \
    "$OUTDIR/pulp-testkey-v6-rsa4k.secret" \
    "$OUTDIR/pulp-testkey-v6-ed25519.secret" \
    "$OUTDIR/pulp-testkey-v6-mldsa65-ed25519.secret" \
    "$OUTDIR/pulp-testkey-v6-mldsa87-ed448.secret" \
    --output "$OUTDIR/pulp-testkey-v6-keyring.secret"

echo "Done. Keys written to $OUTDIR/"
