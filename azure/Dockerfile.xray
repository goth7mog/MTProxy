FROM alpine:3.19

USER root

RUN apk add --no-cache wget ca-certificates tar

# Install dnscrypt-proxy
RUN ARCH=$(uname -m) && \
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

# Install Xray-core
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
    XRAY_URL="https://github.com/XTLS/Xray-core/releases/download/v1.8.8/Xray-linux-64.zip" ; \
    elif [ "$ARCH" = "aarch64" ]; then \
    XRAY_URL="https://github.com/XTLS/Xray-core/releases/download/v1.8.8/Xray-linux-arm64-v8a.zip" ; \
    else \
    echo "Unsupported architecture: $ARCH" && exit 1 ; \
    fi && \
    wget -O /tmp/xray.zip "$XRAY_URL" && \
    unzip /tmp/xray.zip -d /tmp/xray && \
    mv /tmp/xray/xray /usr/local/bin/xray && \
    chmod +x /usr/local/bin/xray && \
    rm -rf /tmp/xray /tmp/xray.zip

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

# Copy xray config
COPY xray-config.json /etc/xray-config.json

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Create non-root user for security
RUN addgroup -g 1000 xray && \
    adduser -D -u 1000 -G xray xray && \
    chown xray:xray /etc/dnscrypt-proxy.toml

# Run as non-root user
USER xray

EXPOSE 8388/tcp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
