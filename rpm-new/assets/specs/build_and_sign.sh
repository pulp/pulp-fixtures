#!/bin/bash
#
# Build a test RPM and produce unsigned, signed, and multi-signed variants.
#
# Requires: rpmbuild, rpmsign, sq (sequoia-sq)
#
# Usage:
#   cd pulp-fixtures/rpm-new/assets/specs && ./build_and_sign.sh
#
# Outputs (in ../packages/):
#   test-package-1.0-1.fc41.noarch.rpm              (unsigned)
#   test-package-signed-1.0-1.fc41.noarch.rpm       (v6 RSA-4096)
#   test-package-multi-signed-1.0-1.fc41.noarch.rpm (v6 RSA-4096 + v6 ML-DSA-87+Ed448)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEYS_DIR="$(cd "$SCRIPT_DIR/../../../common/signing_keys" && pwd)"
PACKAGES_DIR="$(cd "$SCRIPT_DIR/../packages" && pwd)"

V4_KEY="$KEYS_DIR/pulp-testkey-v4-rsa4k.secret"
V6_KEY="$KEYS_DIR/pulp-testkey-v6-mldsa87-ed448.secret"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

RPMBUILD_DIR="$WORK_DIR/rpmbuild"
mkdir -p "$RPMBUILD_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Import both keys into the sequoia key store and authenticate them
sq key import "$V4_KEY"
sq key import "$V6_KEY"

V4_FP=$(sq inspect "$V4_KEY" 2>/dev/null | grep -oP '(?<=Fingerprint: )[A-F0-9]+' | head -1)
V6_FP=$(sq inspect "$V6_KEY" 2>/dev/null | grep -oP '(?<=Fingerprint: )[A-F0-9]+' | head -1)
sq pki link add --cert "$V4_FP" --all
sq pki link add --cert "$V6_FP" --all

# Sequoia signing options for rpmsign --rpmv6
# Override __sq_sign_cmd to use --signer-userid (key name) instead of --signer
# (fingerprint), matching the pattern from rpm-rs's build_packages.sh.
SQ=$(command -v sq)
SQ_OPTS=(
    --define "_openpgp_sign sq"
    --define "__sq ${SQ}"
    --define '__sq_sign_cmd() %{shescape:%{__sq}} sign %{?_openpgp_sign_id:--signer-userid %{_openpgp_sign_id}} %{?_sq_sign_cmd_extra_args} --binary --signature-file %{shescape:%{2}} -- %{shescape:%{1}}'
)
V4_RSA_OPTS=( "${SQ_OPTS[@]}" --define "_gpg_name pulp-testkey-v4-rsa4k" )
V6_MLDSA_OPTS=( "${SQ_OPTS[@]}" --define "_gpg_name pulp-testkey-v6-mldsa87-ed448" )

# Build the RPM
cp "$SCRIPT_DIR/test-package.spec" "$RPMBUILD_DIR/SPECS/"
rpmbuild -bb --define "_topdir $RPMBUILD_DIR" "$RPMBUILD_DIR/SPECS/test-package.spec"

RPM_FILE=$(find "$RPMBUILD_DIR/RPMS" -name "*.rpm" | head -1)
RPM_BASENAME=$(basename "$RPM_FILE")
echo "Built: $RPM_BASENAME"

# 1. Unsigned
cp "$RPM_FILE" "$PACKAGES_DIR/$RPM_BASENAME"
echo "  -> $RPM_BASENAME (unsigned)"

# 2. Signed (RSA-4096, v6 signature packet via sequoia)
SIGNED_NAME="${RPM_BASENAME/test-package-/test-package-signed-}"
cp "$RPM_FILE" "$PACKAGES_DIR/$SIGNED_NAME"
rpmsign --rpmv6 --addsign "${V4_RSA_OPTS[@]}" "$PACKAGES_DIR/$SIGNED_NAME"
echo "  -> $SIGNED_NAME (v6 signed, RSA-4096)"

# 3. Multi-signed (RSA-4096 + ML-DSA-87+Ed448, both v6 signature packets)
MULTI_NAME="${RPM_BASENAME/test-package-/test-package-multi-signed-}"
cp "$PACKAGES_DIR/$SIGNED_NAME" "$PACKAGES_DIR/$MULTI_NAME"
rpmsign --rpmv6 --addsign "${V6_MLDSA_OPTS[@]}" "$PACKAGES_DIR/$MULTI_NAME"
echo "  -> $MULTI_NAME (v6 multi-signed, RSA-4096 + ML-DSA-87+Ed448)"

echo "Done. Packages in $PACKAGES_DIR/"
