#!/usr/bin/env bash
set -euo pipefail

CHANNEL="${1:-}"
VERSION="${2:-}"
FRONT_JSON="${3:-}"
BACK_JSON="${4:-}"

if [[ -z "$CHANNEL" || -z "$VERSION" ]]; then
  echo "Usage: report_system_version.sh <dev|latest> <version> [front_json] [back_json]"
  exit 1
fi

if [[ "$CHANNEL" != "dev" && "$CHANNEL" != "latest" ]]; then
  echo "Invalid channel: $CHANNEL"
  exit 1
fi

if [[ -z "${MS_SYSTEM_VERSION_REPORT_URL:-}" ]]; then
  echo "MS_SYSTEM_VERSION_REPORT_URL is required"
  exit 1
fi

if [[ -z "${MS_SYSTEM_VERSION_REPORT_AUTH_TOKEN:-}" ]]; then
  echo "MS_SYSTEM_VERSION_REPORT_AUTH_TOKEN is required"
  exit 1
fi

if [[ -z "${GITHUB_REPOSITORY:-}" ]]; then
  echo "GITHUB_REPOSITORY is required"
  exit 1
fi

if [[ -z "$FRONT_JSON" || -z "$BACK_JSON" ]]; then
  if [[ "$CHANNEL" == "dev" ]]; then
    FRONT_JSON="./upgrade/dev/dev-front.json"
    BACK_JSON="./upgrade/dev/dev-back.json"
  else
    FRONT_JSON="./upgrade/latest/latest-front.json"
    BACK_JSON="./upgrade/latest/latest-back.json"
  fi
fi

# Debug: Print all input parameters
echo "[report_system_version] === Debug Info ==="
echo "[report_system_version] CHANNEL: $CHANNEL"
echo "[report_system_version] VERSION: $VERSION"
echo "[report_system_version] FRONT_JSON: $FRONT_JSON (exists: $(test -f "$FRONT_JSON" && echo "yes" || echo "no"))"
echo "[report_system_version] BACK_JSON: $BACK_JSON (exists: $(test -f "$BACK_JSON" && echo "yes" || echo "no"))"
echo "[report_system_version] GITHUB_REPOSITORY: $GITHUB_REPOSITORY"
echo "[report_system_version] MS_SYSTEM_VERSION_REPORT_URL: $MS_SYSTEM_VERSION_REPORT_URL"

released_at=$(date +%s)
release_base="https://github.com/${GITHUB_REPOSITORY}/releases/download/${VERSION}"
amd64_url="${release_base}/mediaSaber-amd64.tar.gz"
arm64_url="${release_base}/mediaSaber-arm64.tar.gz"
amd64_sha256=""
arm64_sha256=""

if [[ -f "release/mediaSaber-amd64.tar.gz" ]]; then
  amd64_sha256=$(sha256sum "release/mediaSaber-amd64.tar.gz" | awk '{print $1}')
fi
if [[ -f "release/mediaSaber-arm64.tar.gz" ]]; then
  arm64_sha256=$(sha256sum "release/mediaSaber-arm64.tar.gz" | awk '{print $1}')
fi

payload=$(python3 - "$CHANNEL" "$VERSION" "$released_at" "$amd64_url" "$arm64_url" "$amd64_sha256" "$arm64_sha256" "$FRONT_JSON" "$BACK_JSON" <<'PY'
import json
import os
import sys

channel, version, released_at, amd64_url, arm64_url, amd64_sha256, arm64_sha256, front_json, back_json = sys.argv[1:]

def read_version_items(path: str, target_version: str, source_type: str):
    if not os.path.exists(path):
        return []
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    for row in data:
        if str(row.get('version', '')) == target_version:
            items = row.get('items', [])
            out = []
            for item in items:
                out.append({
                    'sourceType': source_type,
                    'commit': item.get('commit', ''),
                    'author': item.get('author', ''),
                    'date': item.get('date', ''),
                    'message': item.get('message', ''),
                })
            return out
    return []

items = []
items.extend(read_version_items(front_json, version, 'front'))
items.extend(read_version_items(back_json, version, 'back'))

payload = {
    'channel': channel,
    'version': version,
    'downloadUrls': [
        {
            'frameworkType': 'amd64',
            'downloadUrl': amd64_url,
            'sha256': amd64_sha256,
        },
        {
            'frameworkType': 'arm64',
            'downloadUrl': arm64_url,
            'sha256': arm64_sha256,
        },
    ],
    'released_at': int(released_at),
    'items': items,
}

print(json.dumps(payload, ensure_ascii=False))
PY
)

# Debug: Print payload
echo "[report_system_version] === Payload Info ==="
echo "[report_system_version] Payload:"
echo "$payload" | python3 -m json.tool 2>/dev/null || echo "$payload"

max_attempts=3
attempt=1
success=0
last_error=""

# Generate traceparent header for distributed tracing
trace_id=$(openssl rand -hex 16)
parent_id=$(openssl rand -hex 8)
trace_parent="00-${trace_id}-${parent_id}-01"

echo "[report_system_version] === Request Info ==="
echo "[report_system_version] URL: ${MS_SYSTEM_VERSION_REPORT_URL}?random=$(date +%s)"
echo "[report_system_version] Headers:"
echo "[report_system_version]   Content-Type: application/json"
echo "[report_system_version]   traceparent: $trace_parent"
echo "[report_system_version]   Authorization: ${MS_SYSTEM_VERSION_REPORT_AUTH_TOKEN:0:10}***${MS_SYSTEM_VERSION_REPORT_AUTH_TOKEN: -10}"

while [[ $attempt -le $max_attempts ]]; do
  echo "[report_system_version] attempt ${attempt}/${max_attempts}"

  if response=$(curl -sS -X POST "${MS_SYSTEM_VERSION_REPORT_URL}?random=$(date +%s)" \
    -H "Content-Type: application/json" \
    -H "Authorization: ${MS_SYSTEM_VERSION_REPORT_AUTH_TOKEN}" \
    -H "traceparent: ${trace_parent}" \
    -d "$payload" 2>&1); then
    echo "[report_system_version] Response: $response"
    if echo "$response" | grep -Eq '"code"\s*:\s*20000'; then
      success=1
      break
    fi
    last_error="API返回非成功code"
  else
    echo "[report_system_version] Curl Error: $response"
    last_error="请求失败(curl error)"
  fi

  if [[ $attempt -lt $max_attempts ]]; then
    sleep_seconds=$((attempt * 2))
    echo "[report_system_version] retry in ${sleep_seconds}s..."
    sleep "$sleep_seconds"
  fi
  attempt=$((attempt + 1))
done

if [[ $success -ne 1 ]]; then
  echo "[report_system_version] failed after ${max_attempts} attempts: ${last_error}"
  exit 1
fi
