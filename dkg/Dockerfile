ARG DGK_UPSTREAM_VERSION
FROM ssvlabs/ssv-dkg:${DGK_UPSTREAM_VERSION}

WORKDIR /

ARG NETWORK
ARG DKG_PORT
ARG STAKER_SCRIPTS_VERSION

RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
    yq inotify-tools jq curl

COPY dkg-config.yml /ssv-dkg/config/dkg-config.yml
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV DKG_PORT=${DKG_PORT} \
    DKG_DATA_DIR=/data/dkg \
    OPERATOR_DATA_DIR=/data/operator \
    NETWORK=${NETWORK} \
    METRICS_PORT=15000 \
    DKG_CONFIG_DIR=/ssv-dkg/config \
    STAKER_SCRIPTS_URL=https://github.com/dappnode/staker-package-scripts/releases/download/${STAKER_SCRIPTS_VERSION}

ADD ${STAKER_SCRIPTS_URL}/dvt_lsd_tools.sh /etc/profile.d/
ENTRYPOINT [ "entrypoint.sh" ]