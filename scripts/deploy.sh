#!/bin/bash
set -eo pipefail

source "${BASH_SOURCE%/*}/_common.sh"

function deploy() {
  normalize-env-vars

  local PASSWORD=$(extract-password)
  if [ -n "$PASSWORD" ]; then
    PASSWORD_OPT="--password=${PASSWORD}"
  fi

  check-required-etherscan-api-key

  # Log the command being issued, making sure not to expose the password
  log "forge create --keystore="$FOUNDRY_ETH_KEYSTORE_FILE" $(sed 's/=.*$/=[REDACTED]/' <<<${PASSWORD_OPT}) $@"
  forge create --keystore="$FOUNDRY_ETH_KEYSTORE_FILE" ${PASSWORD_OPT} $@
}

function check-required-etherscan-api-key() {
  local msg=$(
    cat <<MSG
ERROR: cannot verify contracts without ETHERSCAN_API_KEY being set.

You should either:

\t1. Not use the --verify flag or;
\t2. Define the ETHERSCAN_API_KEY env var.
MSG
  )

  # Require the Etherscan API Key if --verify option is enabled
  set +e
  if grep -- '--verify' <<<"$@" >/dev/null; then
    [ -n "$FOUNDRY_ETHERSCAN_API_KEY" ] || die "$msg"
  fi
  set -e
}

function usage() {
  cat <<MSG
deploy.sh contract_path [--constructor-args ...args]

Examples:

\t# Constructor does not take any arguments
\tdeploy.sh src/MyContract.sol:MyContract

\t# Constructor takes (uint, address) arguments
\tdeploy.sh src/MyContract.sol:MyContract --constructor-args 1 0x0000000000000000000000000000000000000000
MSG
}

# Executes the function if it's been called as a script.
# This will evaluate to false if this script is sourced by other script.
if [ "$0" = "$BASH_SOURCE" ]; then
  if [ $# -eq 0 ]; then
    die "$(usage)"
  fi

  [ "$1" = '-h' ] || [ "$1" = '--help' ] && {
    log "$(usage)"
    exit 0
  }

  deploy $@
fi
