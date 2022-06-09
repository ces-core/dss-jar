#!/bin/bash
set -eo pipefail

source "${BASH_SOURCE%/*}/_common.sh"

function verify() {
  normalize-env-vars
  check-required-etherscan-api-key

  local ADDRESS="$1"
  local CONTRACT="$2"
  local CONSTRUCTOR_ARGS="$3"

  local CONSTRUCTOR_ARGS_OPT=''
  if [ -n "$CONSTRUCTOR_ARGS" ]; then
    # Remove the 0x prefix from the constructor args
    CONSTRUCTOR_ARGS_OPT="--constructor-args ${CONSTRUCTOR_ARGS#0x}"
  fi

  local CHAIN="$(cast chain)"
  [ CHAIN = 'ethlive' ] && CHAIN='mainnet'

  verify-msg() {
    cat <<MSG
forge verify-contract \\
  --chain "$CHAIN" \\
  "$ADDRESS" "$CONTRACT" "$FOUNDRY_ETHERSCAN_API_KEY" $CONSTRUCTOR_ARGS_OPT
MSG
  }

  log "$(verify-msg)\n"

  forge verify-contract \
    --chain "$CHAIN" --watch \
    "$ADDRESS" "$CONTRACT" "$FOUNDRY_ETHERSCAN_API_KEY" $CONSTRUCTOR_ARGS_OPT
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

  [ -n "$FOUNDRY_ETHERSCAN_API_KEY" ] || die "$msg"
}

function usage() {
  cat <<MSG
verify.sh --address <address> --contract <file.sol>:<contract> [--constructor-args <abi_encoded_args)>]

Examples:

\t# Constructor does not take any arguments
\tverify.sh --address 0xdead...0000  --contract src/MyContract.sol:MyContract

\t# Constructor takes (uint, address) arguments. Don't forget to abi-encode them!
\tverify.sh 0xdead...0000 src/MyContract.sol:MyContract \\
\t\t--constructor-args="\$(cast abi-encode 'constructor(uint, address)' 1 0x0000000000000000000000000000000000000000)"
MSG
}

# Executes the function if it's been called as a script.
# This will evaluate to false if this script is sourced by other script.
if [ "$0" = "$BASH_SOURCE" ]; then
  optspec="h-:"

  address=
  contract=
  constructor_args=

  while getopts "$optspec" OPT; do
    # support long options: https://stackoverflow.com/a/28466267/519360
    if [ "$OPT" = "-" ]; then # long option: reformulate OPT and OPTARG
      OPT="${OPTARG%%=*}"     # extract long option name
      OPTARG="${OPTARG#$OPT}" # extract long option argument (may be empty)
      OPTARG="${OPTARG#=}"    # if long option argument, remove assigning `=`
    fi

    case "$OPT" in
    h | help)
      usage
      exit 0
      ;;
    address)
      [ -z "$OPTARG" ] && {
        log "\n--address option is missing its argument\n"
        die "$(usage)"
      }
      address="$OPTARG"
      ;;
    contract)
      [ -z "$OPTARG" ] && {
        log "\n--contract option is missing its argument\n"
        die "$(usage)"
      }
      contract="$OPTARG"
      ;;
    constructor-args)
      [ -z "$OPTARG" ] && {
        log "\n--constructor-args option is missing its argument\n"
        die "$(usage)"
      }
      constructor_args="$OPTARG"
      ;;
    ??*)
      # bad long option
      log "\nIllegal option --$OPT\n"
      die "$(usage)"
      ;;
    ?)
      log "\nIllegal option -${BOLD}$OPTARG${OFF}\n"
      die "$(usage)"
      ;;
    esac
  done
  shift $((OPTIND - 1))

  verify "$address" "$contract" "$constructor_args"
fi
