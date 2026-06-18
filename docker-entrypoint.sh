#!/bin/sh
set -e

kong migrations bootstrap

kong prepare

if [ -d /docker-entrypoint-init.d ]; then
  (
    for i in $(seq 1 30); do
      if curl -s -o /dev/null http://localhost:8001/status 2>/dev/null; then
        for f in /docker-entrypoint-init.d/*.sh; do
          if [ -f "$f" ]; then
            chmod +x "$f"
            "$f"
          fi
        done
        break
      fi
      sleep 1
    done
  ) &
fi

exec /usr/local/openresty/nginx/sbin/nginx \
  -p /usr/local/kong \
  -c /usr/local/kong/nginx.conf \
  -g "daemon off;"
