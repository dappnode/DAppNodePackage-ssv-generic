#!/bin/bash

export OPERATOR_DB_DIR=${OPERATOR_DATA_DIR}/db
export OPERATOR_CONFIG_DIR=${OPERATOR_DATA_DIR}/config
export OPERATOR_LOGS_DIR=${OPERATOR_DATA_DIR}/logs

export PRIVATE_KEY_FILE=${OPERATOR_CONFIG_DIR}/encrypted_private_key.json
export PRIVATE_KEY_PASSWORD_FILE=${OPERATOR_CONFIG_DIR}/private_key_password
export NODE_CONFIG_FILE=${NODE_CONFIG_DIR}/node-config.yml
export NODE_LOG_FILE=${OPERATOR_LOGS_DIR}/node.log

# Temporary files
DEFAULT_PRIVATE_KEY_FILE=/encrypted_private_key.json
RAW_NODE_YML_CONFIG_FILE=${NODE_CONFIG_DIR}/raw-node-config.yml

SUPPORTED_NETWORKS="mainnet holesky"

# To use staker scripts
# shellcheck disable=SC1091
. /etc/profile

create_directories() {
  mkdir -p "${OPERATOR_CONFIG_DIR}" "${OPERATOR_DB_DIR}" "${OPERATOR_LOGS_DIR}"
}

assign_execution_endpoint() {
  # TODO: Set all execution clients WS port to 8546
  EXECUTION_LAYER_WS=$(get_execution_ws_url_from_global_env "$NETWORK" "$SUPPORTED_NETWORKS")

  export EXECUTION_LAYER_WS
}

assign_beacon_endpoint() {
  BEACON_NODE_API=$(get_beacon_api_url_from_global_env "$NETWORK" "$SUPPORTED_NETWORKS")

  export BEACON_NODE_API
}

handle_password() {
  if [ -f "${PRIVATE_KEY_PASSWORD_FILE}" ]; then
    STORED_PRIVATE_KEY_PASS=$(<"${PRIVATE_KEY_PASSWORD_FILE}")
    if [ -n "${PRIVATE_KEY_PASS}" ] && [ "${PRIVATE_KEY_PASS}" != "${STORED_PRIVATE_KEY_PASS}" ]; then
      echo "[INFO] The private key password has changed. Updating it..."
      mv "${PRIVATE_KEY_FILE}" "${PRIVATE_KEY_FILE}.old"
      echo "${PRIVATE_KEY_PASS}" >"${PRIVATE_KEY_PASSWORD_FILE}"
    fi
  elif [ -n "${PRIVATE_KEY_PASS}" ]; then
    echo "[INFO] Storing the private key password..."
    echo "${PRIVATE_KEY_PASS}" >"${PRIVATE_KEY_PASSWORD_FILE}"
  else
    echo "[INFO] Generating a random password for the operator keys..."
    openssl rand -base64 12 >"${PRIVATE_KEY_PASSWORD_FILE}"
  fi
}

handle_private_key() {
  if [ ! -f "${PRIVATE_KEY_FILE}" ]; then
    if [ ! -f "${DEFAULT_PRIVATE_KEY_FILE}" ]; then
      echo "[INFO] Generating operator keys..."
      /go/bin/ssvnode generate-operator-keys --password-file "${PRIVATE_KEY_PASSWORD_FILE}"
    fi
    echo "[INFO] Moving private key to the proper location..."
    mv "${DEFAULT_PRIVATE_KEY_FILE}" "${PRIVATE_KEY_FILE}"
  else
    echo "[INFO] Operator keys already exist"
  fi
}

post_pubkey_to_dappmanager() {
  PUBLIC_KEY=$(jq -r '.pubKey' "${PRIVATE_KEY_FILE}")

  # If the PUBLIC_KEY is empty, try extracting using the '.publicKey' field (for previous SSV versions)
  if [ -z "$PUBLIC_KEY" ] || [ "$PUBLIC_KEY" = "null" ]; then
    PUBLIC_KEY=$(jq -r '.publicKey' "${PRIVATE_KEY_FILE}")
  fi

  curl --connect-timeout 5 \
    --max-time 10 \
    --silent \
    --retry 5 \
    --retry-delay 0 \
    --retry-max-time 40 \
    -X POST "http://dappmanager.dappnode/data-send?key=NodePublicKey&data=${PUBLIC_KEY}" ||
    {
      echo -e "[ERROR] failed to post public key to dappmanager\n"
    }

  echo "[INFO] You must use the following public key to register your node on the SSV network:"
  echo -e "\nPUBLIC_KEY=${PUBLIC_KEY}\n"
}

create_operator_config() {
  local raw_json_config_file=${NODE_CONFIG_DIR}/raw-node-config.json
  local modified_json_config_file=${NODE_CONFIG_DIR}/modified-node-config.json

  echo "[INFO] Converting YAML config to JSON..."
  ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.load(ARGF))' <"${RAW_NODE_YML_CONFIG_FILE}" >"${raw_json_config_file}"

  echo "[INFO] Modifying the operator config..."
  jq '.global.LogLevel = env.LOG_LEVEL |
      .global.LogFilePath = env.NODE_LOG_FILE |
      .global.LogFileBackups = env.LOG_FILE_BACKUPS |
      .db.Path = env.OPERATOR_DB_DIR |
      .ssv.Network = env.NETWORK |
      .ssv.ValidatorOptions.BuilderProposals = (env.BUILDER_PROPOSALS == "true") |
      .eth2.BeaconNodeAddr = env.BEACON_NODE_API |
      .eth1.ETH1Addr = env.EXECUTION_LAYER_WS |
      .p2p.TCPPort = env.P2P_TCP_PORT |
      .p2p.UDPPort = env.P2P_UDP_PORT |
      .KeyStore.PrivateKeyFile = env.PRIVATE_KEY_FILE |
      .KeyStore.PasswordFile = env.PRIVATE_KEY_PASSWORD_FILE' "${raw_json_config_file}" >"${modified_json_config_file}"

  echo "[INFO] Converting JSON config back to YAML..."
  ruby -ryaml -rjson -e 'puts YAML.dump(JSON.parse(ARGF.read))' <"${modified_json_config_file}" >"${NODE_CONFIG_FILE}"

  echo "[INFO] Cleaning up temporary files..."
  rm -f "${raw_json_config_file}" "${modified_json_config_file}"
}

# Parses numbers between quotes into integers
parse_numbers_in_operator_config() {
  echo "[INFO] Parsing numbers in the operator config..."
  sed -i "s/'\([0-9]\+\)'/\1/g" "${NODE_CONFIG_FILE}"
}

start_operator() {
  echo "[INFO] Starting SSV operator..."

  /go/bin/ssvnode start-node --config "${NODE_CONFIG_FILE}" "${EXTRA_OPTS}" &

  wait $!
  EXIT_STATUS=$?

  # Backup restoring causes the operator to find a mismatch in the DB
  if [ $EXIT_STATUS -ne 0 ] && grep -q "operator private key is not matching the one encrypted the storage" "${NODE_LOG_FILE}"; then
    echo "[WARN] Detected private key mismatch, probably due to backup restoring. Removing DB and retrying..."
    # Added :? to prevent accidental deletion of root directory (if $OPERATOR_DB_DIR is empty or unset)
    rm -rf "${OPERATOR_DB_DIR:?}"/*

    exec /go/bin/ssvnode start-node --config "${NODE_CONFIG_FILE}" "${EXTRA_OPTS}"
  else
    exit $EXIT_STATUS
  fi
}

main() {
  create_directories
  assign_execution_endpoint
  assign_beacon_endpoint
  handle_password
  handle_private_key
  post_pubkey_to_dappmanager
  create_operator_config
  parse_numbers_in_operator_config
  start_operator
}

main
