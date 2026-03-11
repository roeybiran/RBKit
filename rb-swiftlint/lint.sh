#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
readonly SCRIPT_DIR
readonly SWIFTLINT_CONFIG_PATH="$SCRIPT_DIR/swiftlint.yml"
readonly SWIFTFORMAT_CONFIG_PATH="$SCRIPT_DIR/airbnb.swiftformat"

# Homebrew installs on Apple Silicon commonly live in /opt/homebrew/bin.
if [[ "$(uname -m)" == "arm64" ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

# NOTE:
# SwiftLint does not reliably skip nested `.build` directories inside local
# packages (for example `Packages/*/.build`) in this workspace.
# To avoid linting dependency checkouts, we pass only git-tracked `.swift`
# files via SCRIPT_INPUT_FILE_* and `--use-script-input-files`.
#
# SwiftFormat behaves correctly here and does not need this workaround.

run_swiftlint() {
  if ! command -v swiftlint >/dev/null 2>&1; then
    echo "warning: \`swiftlint\` command not found - See https://github.com/realm/SwiftLint#installation for installation instructions."
    return 0
  fi

  local i=0

  while IFS= read -r -d '' file; do
    export "SCRIPT_INPUT_FILE_${i}=$PWD/$file"
    i=$((i + 1))
  done < <(git ls-files -z '*.swift')

  export SCRIPT_INPUT_FILE_COUNT="$i"
  echo "Running swiftlint..."
  swiftlint lint --progress --config "$SWIFTLINT_CONFIG_PATH" --use-script-input-files
}

run_swiftformat() {
  if ! command -v swiftformat >/dev/null 2>&1; then
    echo "warning: \`swiftformat\` command not found - See https://github.com/nicklockwood/SwiftFormat#installation for installation instructions."
    return 0
  fi

  if ! swiftformat --rules | grep -q "redundantSwiftTestingSuite"; then
    echo "error: installed swiftformat ($(swiftformat --version)) does not support rule 'redundantSwiftTestingSuite' in $SWIFTFORMAT_CONFIG_PATH."
    echo "error: upgrade swiftformat to a newer version, then rerun with --fix."
    return 1
  fi

  echo "Running swiftformat..."
  swiftformat . --config "$SWIFTFORMAT_CONFIG_PATH"
}

if [[ "$#" -gt 1 ]]; then
  echo "error: unsupported arguments."
  echo "usage: $0 [--fix]"
  exit 1
fi

case "${1:-}" in
  "")
    run_swiftlint
    ;;
  "--fix")
    run_swiftformat
    run_swiftlint
    ;;
  *)
    echo "error: unsupported argument: ${1}"
    echo "usage: $0 [--fix]"
    exit 1
    ;;
esac
