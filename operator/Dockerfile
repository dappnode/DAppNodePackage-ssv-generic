ARG OPERATOR_UPSTREAM_VERSION

FROM bloxstaking/ssv-node:${OPERATOR_UPSTREAM_VERSION}

ARG NETWORK
ARG P2P_TCP_PORT
ARG P2P_UDP_PORT
ARG STAKER_SCRIPTS_VERSION

ENV OPERATOR_DATA_DIR=/data/operator \
    NODE_CONFIG_DIR=/ssv-node/config \
    METRICS_PORT=15000 \
    STAKER_SCRIPTS_URL=https://github.com/dappnode/staker-package-scripts/releases/download/${STAKER_SCRIPTS_VERSION}

ADD ${STAKER_SCRIPTS_URL}/dvt_lsd_tools.sh /etc/profile.d/

COPY node-config.yml /ssv-node/config/raw-node-config.yml
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apt-get update && \
    apt-get install -y curl jq ruby openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /data/operator/config && \
    chmod +rx /etc/profile.d/dvt_lsd_tools.sh /usr/local/bin/entrypoint.sh

# Placed here to rebuild less layers
ENV P2P_TCP_PORT=${P2P_TCP_PORT} \ 
    P2P_UDP_PORT=${P2P_UDP_PORT} \
    NETWORK=${NETWORK}

ENTRYPOINT [ "entrypoint.sh" ]