FROM kong:latest

USER root
RUN \
  if command -v apt-get > /dev/null; then \
    apt-get update && apt-get install -y curl --no-install-recommends && rm -rf /var/lib/apt/lists/*; \
  elif command -v apk > /dev/null; then \
    apk add --no-cache curl; \
  fi
USER kong

ENV KONG_NGINX_MAIN_DAEMON=off
ENV KONG_ADMIN_LISTEN=127.0.0.1:8001
ENV KONG_DNS_RESOLVER=8.8.8.8

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY kong-init.sh /docker-entrypoint-init.d/kong-init.sh

EXPOSE 8000 8001

ENTRYPOINT ["/docker-entrypoint.sh"]
