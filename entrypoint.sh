#!/bin/bash

# 启动阶段分段耗时打点（docker logs 可见）：2026-11-18 取证「容器 start → Go main」
# 约 51s 空窗，逐段暴露 entrypoint 内开销大头（此前不可见）
T0=$(date +%s)

# 检查并创建目录
mkdir -p /app/config/nginx/vhost
mkdir -p /app/config/nginx/log
mkdir -p /app/config/data/nginx/emby/images
mkdir -p /app/config/data/nginx/emby/subtitles
mkdir -p /app/config/data/site_config/commons
mkdir -p /app/config/data/site_config/sites
mkdir -p /app/config/data/static/site_favicon
mkdir -p /app/config/data/static/level_icon
mkdir -p /app/config/data/static/wallpaper

envsubst '${MS_PORT}' < /etc/nginx/nginx.template.conf > /etc/nginx/nginx.conf
groupmod -o -g "${PGID}" msaber
usermod -o -u "${PUID}" msaber
echo "[entrypoint] 阶段1 目录/envsubst/用户 就绪，耗时 $(( $(date +%s) - T0 ))s"
T0=$(date +%s)

chown msaber:msaber -R \
    /app \
    /var/lib/nginx \
    /run/nginx \
    /var/log/nginx \
    /etc/nginx
echo "[entrypoint] 阶段2 chown(收窄范围) 完成，耗时 $(( $(date +%s) - T0 ))s"
T0=$(date +%s)

nginx
echo "[entrypoint] 阶段3 nginx 就绪，耗时 $(( $(date +%s) - T0 ))s"
cd /app || exit
umask "${UMASK}"
exec su-exec msaber:msaber /app/mediaSaber

# exec su-exec msaber:msaber dlv --listen=:2345 --headless=true --api-version=2 --accept-multiclient exec /app/mediaSaber
