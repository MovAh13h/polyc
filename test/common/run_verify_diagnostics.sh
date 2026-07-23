#!/usr/bin/env bash
# Diagnostics test runner for polyc.
#
# Usage:
#   run_verify_diagnostics.sh <polyc-opt-path> <input.mlir>
#
# Runs `polyc-opt --verify-diagnostics --split-input-file <src>`. Each
# snippet in <src> (separated by `// -----`) is verified independently;
# `// expected-error` directives assert which diagnostics must fire.
#
# Exits 0 iff every expected diagnostic fires and no unexpected ones do.
set -euo pipefail

POLYC_OPT="$1"
SRC="$2"

"$POLYC_OPT" --verify-diagnostics --split-input-file "$SRC"
