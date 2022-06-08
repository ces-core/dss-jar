#!/bin/bash
set -eo pipefail

source "${BASH_SOURCE%/*}/_common.sh"

function create-jar() {
  local FACTORY="$1"
  local ILK="$2"
  local DAI_JOIN="$3"
  local VOW=$4
  shift 4;

  normalize-env-vars

  local PASSWORD=$(extract-password)
  if [ -n "$PASSWORD" ]; then
    PASSWORD_OPT="--password=${PASSWORD}"
  fi

  tx-msg() {
    cat <<MSG
cast send --keystore="$FOUNDRY_ETH_KEYSTORE_FILE" $(sed 's/=.*$/=[REDACTED]/' <<<${PASSWORD_OPT}) \\
  --cast-async \\
  "${FACTORY}" 'createJar(bytes32,address,address)' "$ILK" "$DAI_JOIN" "$VOW"
MSG
  }

  log "$(tx-msg)\n"

  TX="$(cast send --keystore="$FOUNDRY_ETH_KEYSTORE_FILE" ${PASSWORD_OPT} \
    --cast-async \
    "${FACTORY}" 'createJar(bytes32,address,address)' "$ILK" "$DAI_JOIN" "$VOW")"
  log "TX: $TX"

  local RECEIPT="$(seth receipt $TX)"
  local TX_STATUS="$(awk '/^status/ { print $2 }' <<<"$RECEIPT")"
  [[ "$TX_STATUS" != "1" ]] && die "Failed to create a Jar in tx ${TX}."

  local JAR=$(cast call "${FACTORY}" 'ilkToJar(bytes32)(address)' "$ILK")
  echo "$JAR"

  sleep 13s
  set +e
  if grep -- '--verify' <<< "$@" > /dev/null; then
    ${BASH_SOURCE%/*}/verify.sh --address="$JAR" --contract='src/Jar.sol:Jar' --constructor-args="$(cast abi-encode 'constructor(address,address)' $DAI_JOIN $VOW)" >&2
  fi
  set -e
}

function usage() {
cat <<MSG
create-jar.sh --factory <factory_address> \\
  --ilk <ascii_encoded_ilk> \\
  --dai-join <dai_join_address> \\
  --vow <vow_address> \\
  [--verify]
MSG
}

# Executes the function if it's been called as a script.
# This will evaluate to false if this script is sourced by other script.
if [ "$0" = "$BASH_SOURCE" ]; then
  optspec="h-:"
  factory=
  ilk=
  dai_join=
  vow=
  verify=0

  while getopts "$optspec" OPT; do
    # support long options: https://stackoverflow.com/a/28466267/519360
    if [ "$OPT" = "-" ]; then   # long option: reformulate OPT and OPTARG
      OPT="${OPTARG%%=*}"       # extract long option name
      OPTARG="${OPTARG#$OPT}"   # extract long option argument (may be empty)
      OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
    fi

    case "$OPT" in
      h | help)
        usage
        exit 0
        ;;
      factory)
        [ -z "$OPTARG" ] && {
          log "\n--factory option is missing its argument\n"
          die "$(usage)"
        }
        factory="$OPTARG"
        ;;
      ilk)
        [ -z "$OPTARG" ] && {
          log "\n--ilk option is missing its argument\n"
          die "$(usage)"
        }
        ilk="$OPTARG"
        ;;
      dai-join)
        [ -z "$OPTARG" ] && {
          log "\n--dai-join option is missing its argument\n"
          die "$(usage)"
        }
        dai_join="$OPTARG"
        ;;
      vow)
        [ -z "$OPTARG" ] && {
          log "\n--vow option is missing its argument\n"
          die "$(usage)"
        }
        vow="$OPTARG"
        ;;
      verify)
        verify=1
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
  shift $((OPTIND-1))

  if [ -z "$factory" ] || [ -z "$ilk" ] || [ -z "$dai_join" ] || [ -z "$vow" ]; then
    die "$(usage)"
  fi

  verify_flag=''
  if [ $verify -eq 1 ]; then
    verify_flag='--verify'
  fi

  create-jar "$factory" "$ilk" "$dai_join" "$vow" $verify_flag
fi
