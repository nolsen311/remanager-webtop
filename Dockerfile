FROM lscr.io/linuxserver/webtop:ubuntu-lxqt

# reManager release tag to install, e.g. v1.7.4 (overridden at build time by CI)
ARG REMANAGER_VERSION=v1.7.4
ARG TARGETARCH

ENV TITLE="reManager"

RUN echo "**** install reManager runtime dependencies ****" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
      libgtk-3-0t64 \
      libwebkit2gtk-4.1-0 \
      gnome-keyring \
      libsecret-1-0 && \
    echo "**** install reManager ${REMANAGER_VERSION} (${TARGETARCH}) ****" && \
    case "${TARGETARCH}" in \
      amd64) RM_ARCH=amd64 ;; \
      arm64) RM_ARCH=arm64 ;; \
      *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac && \
    curl -fsSL -o /tmp/remanager.tar.gz \
      "https://github.com/rmitchellscott/reManager/releases/download/${REMANAGER_VERSION}/reManager-linux-${RM_ARCH}.tar.gz" && \
    mkdir -p /opt/remanager && \
    tar -xzf /tmp/remanager.tar.gz -C /opt/remanager && \
    chmod +x /opt/remanager/reManager && \
    ln -sf /opt/remanager/reManager /usr/local/bin/reManager && \
    echo "**** cleanup ****" && \
    apt-get autoclean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# custom-cont-init.d script that (re)writes the desktop autostart entry on
# every container start, so upgrading the image also updates an existing
# named /config volume (linuxserver only seeds defaults on a fresh volume)
COPY rootfs/ /

EXPOSE 3001
VOLUME /config
