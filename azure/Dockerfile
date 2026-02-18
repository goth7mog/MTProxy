# Dockerfile for Shadowsocks-libev with local DoH DNS proxy (dnscrypt-proxy)
FROM shadowsocks/shadowsocks-libev:latest

USER root

# Install wget, ca-certificates, and dnscrypt-proxy with all necessary files
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

# Install v2ray-plugin
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
    V2RAY_URL="https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.2/v2ray-plugin-linux-amd64-v1.3.2.tar.gz" ; \
    BINARY="v2ray-plugin_linux_amd64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
    V2RAY_URL="https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.2/v2ray-plugin-linux-arm64-v1.3.2.tar.gz" ; \
    BINARY="v2ray-plugin_linux_arm64"; \
    else \
    echo "Unsupported architecture: $ARCH" && exit 1 ; \
    fi && \
    wget -O /tmp/v2ray-plugin.tar.gz "$V2RAY_URL" && \
    tar -xzf /tmp/v2ray-plugin.tar.gz -C /tmp && \
    mv /tmp/$BINARY /usr/local/bin/v2ray-plugin && \
    chmod +x /usr/local/bin/v2ray-plugin && \
    rm -rf /tmp/v2ray-plugin*

# Install ngrok
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
    NGROK_URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz" ; \
    elif [ "$ARCH" = "aarch64" ]; then \
    NGROK_URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz" ; \
    else \
    echo "Unsupported architecture: $ARCH" && exit 1 ; \
    fi && \
    wget -O /tmp/ngrok.tgz "$NGROK_URL" && \
    tar -xzf /tmp/ngrok.tgz -C /tmp && \
    cp /tmp/ngrok /usr/local/bin/ && \
    chmod +x /usr/local/bin/ngrok && \
    rm -rf /tmp/ngrok*


# Copy dnscrypt-proxy config
COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy.toml

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Create non-root user for security
RUN addgroup -g 1000 shadowsocks && \
    adduser -D -u 1000 -G shadowsocks shadowsocks && \
    chown shadowsocks:shadowsocks /etc/dnscrypt-proxy.toml

# Run as non-root user
USER shadowsocks

EXPOSE 8388/tcp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
