FROM kong:latest

ENV KONG_NGINX_MAIN_DAEMON=off

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY kong-init.sh /docker-entrypoint-init.d/kong-init.sh

EXPOSE 8000 8001

ENTRYPOINT ["/docker-entrypoint.sh"]
