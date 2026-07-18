#!/usr/bin/env bash
# Round-trip test runner for polyc.
#
# Usage:
#   run_roundtrip.sh <polyc-opt-path> <FileCheck-path> <input.mlir>
#
# Runs `polyc-opt <src> | polyc-opt | FileCheck <src>`. The second pass
# proves the printer/parser pair is idempotent; the FileCheck directives
# in the source describe what the canonical printed form should look
# like.
#
# Exits 0 if all CHECKs match, nonzero otherwise.
set -euo pipefail

POLYC_OPT="$1"
FILECHECK="$2"
SRC="$3"

"$POLYC_OPT" "$SRC" | "$POLYC_OPT" | "$FILECHECK" "$SRC"
