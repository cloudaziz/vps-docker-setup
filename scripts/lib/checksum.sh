#!/usr/bin/env bash

set -euo pipefail

verify_checksum() {

    local FILE="$1"
    local CHECKSUM_FILE="${FILE}.sha256"

    if [ ! -f "$FILE" ]; then
        echo "ERROR: Backup file not found."
        echo "File : $FILE"
        exit 1
    fi

    if [ ! -f "$CHECKSUM_FILE" ]; then
        echo "ERROR: Checksum file not found."
        echo "File : $CHECKSUM_FILE"
        exit 1
    fi

    (
        cd "$(dirname "$FILE")"
        sha256sum -c "$(basename "$CHECKSUM_FILE")"
    )
}
