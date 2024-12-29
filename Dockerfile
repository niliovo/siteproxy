FROM alpine AS prebuild
WORKDIR /
RUN apk add git && \
git clone https://github.com/netptop/siteproxy

FROM node:slim
WORKDIR /home/node/siteproxy/
ENV PROXY_URL={PROXY_URL:-http://localhost:5006}
ENV TOKEN_PREFIX={TOKEN_PREFIX:-/user22334455/}
ENV LOCAL_LISTEN_PORT={LOCAL_LISTEN_PORT:-5006}

COPY --from=prebuild /siteproxy/bundle.js .

RUN cat <<'EOF' > entrypoint.sh
#!/bin/bash
if [ ! -f "config.json" ]; then
    echo "{
  \"proxy_url\": \"${PROXY_URL}\",
  \"token_prefix\": \"${TOKEN_PREFIX}\",
  \"local_listen_port\": ${LOCAL_LISTEN_PORT}
}"> config.json
fi
node /home/node/siteproxy/bundle.js
EOF

EXPOSE 5006

RUN chmod +x entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]