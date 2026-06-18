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

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY kong-init.sh /docker-entrypoint-init.d/kong-init.sh

EXPOSE 8000 8001

ENTRYPOINT ["/docker-entrypoint.sh"]
