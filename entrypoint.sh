#!/usr/bin/env bash

# inject BASE_URL at runtime
find /usr/share/nginx/html \(-name "*mirrorlist*" -o -name "*.html" \) \
  -exec sed -i -e "s%BASE_URL%$BASE_URL%g" {} +

nginx -g 'daemon off;'
