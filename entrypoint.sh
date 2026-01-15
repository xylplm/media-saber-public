#!/bin/bash

# 检查并创建目录
mkdir -p /app/config/data/nginx/emby/images
mkdir -p /app/config/data/nginx/emby/subtitles
mkdir -p /app/config/data/site_config/commons
mkdir -p /app/config/data/site_config/sites
mkdir -p /app/config/data/static/site_favicon
mkdir -p /app/config/data/static/level_icon

groupmod -o -g "${PGID}" msaber
usermod -o -u "${PUID}" msaber

chown msaber:msaber -R /app

cd /app || exit
umask "${UMASK}"
exec su-exec msaber:msaber /app/mediaSaber

# exec su-exec msaber:msaber dlv --listen=:2345 --headless=true --api-version=2 --accept-multiclient exec /app/mediaSaber