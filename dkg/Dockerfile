ARG DGK_UPSTREAM_VERSION

FROM bloxstaking/ssv-dkg:${DGK_UPSTREAM_VERSION}

ARG NETWORK
ARG DKG_PORT

RUN apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
    yq inotify-tools jq curl

COPY dkg-config.yml /ssv-dkg/config/dkg-config.yml
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENV DKG_PORT=${DKG_PORT} \
    DKG_DATA_DIR=/data/dkg \
    OPERATOR_DATA_DIR=/data/operator \
    NETWORK=${NETWORK} \
    METRICS_PORT=15000 \
    DKG_CONFIG_DIR=/ssv-dkg/config

ENTRYPOINT [ "entrypoint.sh" ]