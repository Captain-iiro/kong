#!/bin/sh
set -e

ADMIN="http://localhost:8001"

echo "Configuring Backend A..."
curl -s -X PUT "$ADMIN/services/backend-a" \
  -H "Content-Type: application/json" \
  -d '{"name":"backend-a","url":"https://test.fleex.tech/api"}' -o /dev/null

curl -s -X PUT "$ADMIN/services/backend-a/routes/route-a" \
  -H "Content-Type: application/json" \
  -d '{"name":"route-a","paths":["/api"]}' -o /dev/null

echo "Configuring Backend B..."
curl -s -X PUT "$ADMIN/services/backend-b" \
  -H "Content-Type: application/json" \
  -d '{"name":"backend-b","url":"https://marketplace.fleexsolutions.tech/api"}' -o /dev/null

curl -s -X PUT "$ADMIN/services/backend-b/routes/route-b" \
  -H "Content-Type: application/json" \
  -d '{"name":"route-b","paths":["/marketplace"]}' -o /dev/null

echo "Configuring plugin X-API-Key on Backend B..."
if [ -n "$KONG_GATEWAY_SECRET" ]; then
  EXISTING=$(curl -s "$ADMIN/services/backend-b/plugins?name=request-transformer" | tr -d '\n ')
  ID=$(echo "$EXISTING" | sed 's/.*"data":\[{"id":"\([^"]*\)".*/\1/')
  if [ "$ID" != "$EXISTING" ]; then
    curl -s -X DELETE "$ADMIN/services/backend-b/plugins/$ID" -o /dev/null
  fi
  curl -s -X POST "$ADMIN/services/backend-b/plugins" \
    -H "Content-Type: application/json" \
    -d "$(printf '{"name":"request-transformer","config":{"add":{"headers":["X-API-Key:%s"]}}}' "$KONG_GATEWAY_SECRET")" -o /dev/null
fi

echo "Init complete."
