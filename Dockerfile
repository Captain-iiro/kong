FROM kong:latest

ENV KONG_NGINX_MAIN_DAEMON=off

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
