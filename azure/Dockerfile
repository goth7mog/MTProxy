# Dockerfile for Shadowsocks-libev with local DoH DNS proxy (cloudflared)
FROM shadowsocks/shadowsocks-libev:latest

USER root

# Install wget, ca-certificates, and dnscrypt-proxy
RUN apk add --no-cache wget ca-certificates tar && \
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
    DNSCRYPT_URL="https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/2.1.15/dnscrypt-proxy-linux_x86_64-2.1.15.tar.gz" ; \
    DIR="linux-x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
    DNSCRYPT_URL="https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/2.1.15/dnscrypt-proxy-linux_arm64-2.1.15.tar.gz" ; \
    DIR="linux-arm64"; \
    else \
    echo "Unsupported architecture: $ARCH" && exit 1 ; \
    fi && \
    wget -O /tmp/dnscrypt-proxy.tar.gz "$DNSCRYPT_URL" && \
    tar -xzf /tmp/dnscrypt-proxy.tar.gz -C /tmp && \
    cp /tmp/$DIR/dnscrypt-proxy /usr/local/bin/ && \
    chmod +x /usr/local/bin/dnscrypt-proxy && \
    rm -rf /tmp/dnscrypt-proxy*

# Copy dnscrypt-proxy config
COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy.toml

EXPOSE 8388/tcp 8388/udp

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["dnscrypt-proxy -config /etc/dnscrypt-proxy.toml & sleep 2 && ss-server -s 0.0.0.0 -p 8388 -m ${SHADOWSOCKS_METHOD:-chacha20-ietf-poly1305} -k ${SHADOWSOCKS_PASSWORD:-password} -u -d 127.0.0.1:5053"]
