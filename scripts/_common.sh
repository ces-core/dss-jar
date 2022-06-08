function normalize-env-vars() {
  local ENV_FILE="${BASH_SOURCE%/*}/../.env"
  [ -f "$ENV_FILE" ] && source "$ENV_FILE"

  export FOUNDRY_ETH_FROM="${FOUNDRY_ETH_FROM:-$ETH_FROM}"
  export FOUNDRY_ETHERSCAN_API_KEY="${FOUNDRY_ETHERSCAN_API_KEY:-$ETHERSCAN_API_KEY}"
  export FOUNDRY_ETH_KEYSTORE_DIRECTORY="${FOUNDRY_ETH_KEYSTORE_DIRECTORY:-$ETH_KEYSTORE}"

  if [ -z "$FOUNDRY_ETH_KEYSTORE_FILE" ]; then
    [ -z "$FOUNDRY_ETH_KEYSTORE_DIRECTORY" ] && die "$(err-msg-keystore-file)"
    # Foundy expects the Ethereum Keystore file, not the directory.
    # This step assumes the Keystore file for the deployed wallet includes $ETH_FROM in its name.
    export FOUNDRY_ETH_KEYSTORE_FILE="${FOUNDRY_ETH_KEYSTORE_DIRECTORY%/}/$(ls -1 $FOUNDRY_ETH_KEYSTORE_DIRECTORY | \
      # -i: case insensitive
      # #0x: strip the 0x prefix from the the address
      grep -i ${FOUNDRY_ETH_FROM#0x})"
  fi

  [ -n "$FOUNDRY_ETH_KEYSTORE_FILE" ] || die "$(err-msg-keystore-file)"
}

# Handle reading from the password file
function extract-password () {
  [ -f "$FOUNDRY_ETH_PASSWORD_FILE" ] && cat "$FOUNDRY_ETH_PASSWORD_FILE"
}

function log() {
  echo -e "$@" >&2
}

function die() {
  log "$@"
  log ""
  exit 1
}

function err-msg-keystore-file() {
cat <<MSG
ERROR: could not determine the location of the keystore file.

You should either define:

\t1. The FOUNDRY_ETH_KEYSTORE_FILE env var or;
\t2. Both FOUNDRY_ETH_KEYSTORE_DIR and FOUNDRY_ETH_FROM env vars.
MSG
}

