# Build stage
FROM alpine:3.21 as build

ARG DGK_UPSTREAM_VERSION

WORKDIR /
RUN cd /

# Install curl and zip
RUN apk update
RUN apk add --no-cache curl zip

# Download given version from Github and unzip
RUN curl -L -o /ssv-dkg.zip https://github.com/ssvlabs/ssv-dkg/releases/download/${DGK_UPSTREAM_VERSION}/ssvdkg-${DGK_UPSTREAM_VERSION}-linux-$(uname -m | sed -e 's/aarch64/arm64/g' -e 's/x86_64/amd64/g').zip
RUN unzip -j /ssv-dkg.zip

# Final stage
FROM alpine:3.21

# Copy the built binary from the previous stage/build context
COPY --from=build /ssv-dkg /bin/ssv-dkg

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

EXPOSE 3030
ENTRYPOINT [ "entrypoint.sh" ]
