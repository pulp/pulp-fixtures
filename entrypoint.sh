#!/usr/bin/env bash

set -e

# inject BASE_URL at runtime
find /usr/share/nginx/html \( -name "*mirrorlist*" -o -name "*.html" -o -name "*.json" \) \
  -exec sed -i -e "s%BASE_URL%$BASE_URL%g" {} +

nginx -g 'daemon off;'
