#!/bin/bash

set -e

RELEASE_FILE="${1}"
OUTPUT_DIR="$(dirname "${1}")"
DETACHED_SIGNATURE_PATH="${OUTPUT_DIR}/Release.gpg"
INLINE_SIGNATURE_PATH="${OUTPUT_DIR}/InRelease"

GPG_KEY_ID="pulp-fixture-signing-key"

COMMON_GPG_OPTS=(
  --batch
  --armor
  --digest-algo
  SHA256
)

# Create a detached signature
/usr/bin/gpg "${COMMON_GPG_OPTS[@]}" \
  --detach-sign \
  --output "${DETACHED_SIGNATURE_PATH}" \
  --local-user "${GPG_KEY_ID}" \
  "${RELEASE_FILE}"

# Create an inline signature
/usr/bin/gpg "${COMMON_GPG_OPTS[@]}" \
  --clearsign \
  --output "${INLINE_SIGNATURE_PATH}" \
  --local-user "${GPG_KEY_ID}" \
  "${RELEASE_FILE}"
