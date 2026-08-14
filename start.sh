#!/bin/sh
set -eu

if [ -z "${DEPLOY_ARCHIVE_KEY:-}" ]; then
  echo "Deployment key is not configured." >&2
  exit 78
fi

if [ -z "${DATABASE_URL:-}" ] && [ -n "${TAMYEZ_DATABASE_URL:-}" ]; then
  export DATABASE_URL="$TAMYEZ_DATABASE_URL"
fi

umask 077
runtime_archive="/tmp/app-runtime.tar.gz"

openssl enc -d -aes-256-cbc -pbkdf2 -iter 20000 -md sha256 \
  -pass env:DEPLOY_ARCHIVE_KEY \
  -in /opt/tamyez/app-runtime.tar.gz.enc \
  -out "$runtime_archive"

expected_hash="$(cat /opt/tamyez/app-runtime.sha256)"
actual_hash="$(sha256sum "$runtime_archive" | awk '{print $1}')"
if [ "$expected_hash" != "$actual_hash" ]; then
  echo "Encrypted runtime verification failed." >&2
  rm -f "$runtime_archive"
  exit 74
fi

rm -rf /app/dist /app/server /app/db /app/base44 /app/server.js
tar -xzf "$runtime_archive" -C /app
rm -f "$runtime_archive"
unset DEPLOY_ARCHIVE_KEY
unset TAMYEZ_DATABASE_URL

exec node server.js
