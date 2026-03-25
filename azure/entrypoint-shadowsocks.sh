#!/bin/sh

# Start dnscrypt-proxy in background
dnscrypt-proxy -config /etc/dnscrypt-proxy.toml &
DNSCRYPT_PID=$!
sleep 2

# Start Shadowsocks server
ss-server -s 0.0.0.0 -p 8388 -m "${SHADOWSOCKS_METHOD:-chacha20-ietf-poly1305}" -k "${SHADOWSOCKS_PASSWORD:-password}" -u -d 127.0.0.1:5053 &
SS_PID=$!


# Start ngrok TCP tunnel on port 8388 if NGROK_AUTHTOKEN is set
if [ -n "$NGROK_AUTHTOKEN" ]; then
    ngrok config add-authtoken "$NGROK_AUTHTOKEN"
    if [ -n "$NGROK_REMOTE_ADDR" ]; then
        # Use predefined tunnel address and optional region
        if [ -n "$NGROK_REGION" ]; then
            ngrok tcp --region="$NGROK_REGION" --remote-addr="$NGROK_REMOTE_ADDR" 8388 --log stdout &
        else
            ngrok tcp --remote-addr="$NGROK_REMOTE_ADDR" 8388 --log stdout &
        fi
    else
        # Use random tunnel
        ngrok tcp 8388 --log stdout &
    fi
    NGROK_PID=$!
fi

# Wait for background processes
wait $DNSCRYPT_PID $SS_PID
