#!/bin/sh
set -e

if [ "$KONG_DATABASE_RESET" = "true" ]; then
  echo "Resetting Kong database..."
  kong migrations reset --force
fi

kong migrations bootstrap

KONG_NGINX_MAIN_DAEMON=on kong start

for i in $(seq 1 30); do
  if curl -s -o /dev/null http://localhost:8001/ 2>/dev/null; then
    break
  fi
  sleep 1
done

for f in /docker-entrypoint-init.d/*.sh; do
  if [ -f "$f" ]; then
    "$f"
  fi
done

exec kong restart
