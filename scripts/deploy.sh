#!/bin/bash
set -eo pipefail

function deploy() {
  local ENV_FILE="${BASH_SOURCE%/*}/../.env"
  [ -f "$ENV_FILE" ] && source "$ENV_FILE"

  FOUNDRY_ETH_FROM="${FOUNDRY_ETH_FROM:-$ETH_FROM}"
  FOUNDRY_ETHERSCAN_API_KEY="${FOUNDRY_ETHERSCAN_API_KEY:-$ETHERSCAN_API_KEY}"
  FOUNDRY_ETH_KEYSTORE_DIRECTORY="${FOUNDRY_ETH_KEYSTORE_DIRECTORY:-$ETH_KEYSTORE}"

  if [ -z "$FOUNDRY_ETH_KEYSTORE_FILE" ]; then
    [ -z "$FOUNDRY_ETH_KEYSTORE_DIRECTORY" ] && die "$(err_msg_keystore_file)"
    # Foundy expects the Ethereum Keystore file, not the directory.
    # This step assumes the Keystore file for the deployed wallet includes $ETH_FROM in its name.
    FOUNDRY_ETH_KEYSTORE_FILE="${FOUNDRY_ETH_KEYSTORE_DIRECTORY%/}/$(ls -1 $FOUNDRY_ETH_KEYSTORE_DIRECTORY | \
      # -i: case insensitive
      # #0x: strip the 0x prefix from the the address
      grep -i ${FOUNDRY_ETH_FROM#0x})"
  fi
  [ -z "$FOUNDRY_ETH_KEYSTORE_FILE" ] && die "$(err_msg_keystore_file)"

  # Handle reading from the password file
  local PASSWORD_OPT=''
  if [ -f "$FOUNDRY_ETH_PASSWORD_FILE" ]; then
    PASSWORD_OPT="--password=$(cat "$FOUNDRY_ETH_PASSWORD_FILE")"
  fi

  # Require the Etherscan API Key if --verify option is enabled
  set +e
  if grep -- '--verify' <<< "$@" > /dev/null; then
    [ -z "$FOUNDRY_ETHERSCAN_API_KEY" ] && die "$(err_msg_etherscan_api_key)"
  fi
  set -e

  # Log the command being issued, making sure not to expose the password
  log "forge create --keystore="$FOUNDRY_ETH_KEYSTORE_FILE" $(sed 's/=.*$/=[REDACTED]/' <<<${PASSWORD_OPT}) $@"
  # forge create --keystore="$FOUNDRY_ETH_KEYSTORE_FILE" ${PASSWORD_OPT} $@
}

function log() {
  echo -e "$@" >&2
}

function die() {
  log "$@"
  log ""
  exit 1
}

function err_msg_keystore_file() {
cat <<MSG
ERROR: could not determine the location of the keystore file.

You should either define:

\t1. The FOUNDRY_ETH_KEYSTORE_FILE env var or;
\t2. Both FOUNDRY_ETH_KEYSTORE_DIR and FOUNDRY_ETH_FROM env vars.
MSG
}

function err_msg_etherscan_api_key() {
cat <<MSG
ERROR: cannot verify contracts without ETHERSCAN_API_KEY being set.

You should either:

\t1. Not use the --verify flag or;
\t2. Define the ETHERSCAN_API_KEY env var.
MSG
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
