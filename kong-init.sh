#!/bin/sh
set -e

ADMIN="http://localhost:8001"

echo "Cleaning up all plugins (recover from bad config)..."
curl -s "$ADMIN/plugins?size=1000" | grep -o '"id":"[^"]*"' | cut -d'"' -f4 | while read id; do
  curl -s -X DELETE "$ADMIN/plugins/$id" -o /dev/null
done 2>/dev/null || true

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

echo "Configuring Admin API loopback for Konga..."
ADMIN_KEY="${KONG_ADMIN_KEY:-${KONG_GATEWAY_SECRET:-changeme}}"

curl -s -X PUT "$ADMIN/consumers/konga-admin" \
  -H "Content-Type: application/json" \
  -d '{"username":"konga-admin"}' -o /dev/null

EXISTING_KEY=$(curl -s "$ADMIN/consumers/konga-admin/key-auth")
OLD_ID=$(echo "$EXISTING_KEY" | sed 's/.*"data":\[{"id":"\([^"]*\)".*/\1/')
if [ "$OLD_ID" != "$EXISTING_KEY" ]; then
  curl -s -X DELETE "$ADMIN/consumers/konga-admin/key-auth/$OLD_ID" -o /dev/null
fi

curl -s -X POST "$ADMIN/consumers/konga-admin/key-auth" \
  -H "Content-Type: application/json" \
  -d "{\"key\":\"$ADMIN_KEY\"}" -o /dev/null

curl -s -X PUT "$ADMIN/services/admin-api" \
  -H "Content-Type: application/json" \
  -d '{"name":"admin-api","url":"http://localhost:8001"}' -o /dev/null

curl -s -X PUT "$ADMIN/services/admin-api/routes/admin-route" \
  -H "Content-Type: application/json" \
  -d '{"name":"admin-route","paths":["/admin-api"]}' -o /dev/null

curl -s -X POST "$ADMIN/routes/admin-route/plugins" \
  -H "Content-Type: application/json" \
  -d '{"name":"key-auth","config":{"key_names":["apikey"],"hide_credentials":true}}' -o /dev/null

echo "Init complete."
