#!/bin/bash

# 检查并创建目录
mkdir -p /app/config/nginx/vhost
mkdir -p /app/config/nginx/log
mkdir -p /app/config/data/nginx/emby/images
mkdir -p /app/config/data/nginx/emby/subtitles
mkdir -p /app/config/data/site_config/commons
mkdir -p /app/config/data/site_config/sites
mkdir -p /app/config/data/static/site_favicon
mkdir -p /app/config/data/static/level_icon

envsubst '${MS_PORT}' < /etc/nginx/nginx.template.conf > /etc/nginx/nginx.conf
groupmod -o -g "${PGID}" msaber
usermod -o -u "${PUID}" msaber

PACKAGE="/app/mediaSaber-upgrade.tar.gz"
UPGRADE_DIR="/app/mediaSaber-upgrade"

if [ -f "$PACKAGE" ]; then
    echo "开始解压..."
    mkdir -p "$UPGRADE_DIR"
    tar -zxf "$PACKAGE" -C "$UPGRADE_DIR"

    ls -l

    echo "替换后端..."
    cp "$UPGRADE_DIR/msaber-back/mediaSaber" /app/mediaSaber
    chmod +x /app/mediaSaber

    echo "替换前端..."
    rm -rf /app/front
    mv "$UPGRADE_DIR/msaber-front" /app/front

    echo "替换配置..."
    rm -rf /app/etc
    mv "$UPGRADE_DIR/msaber-back/etc" /app/etc

    rm -rf /app/doc
    mv "$UPGRADE_DIR/msaber-back/doc" /app/doc

    rm -rf /app/static
    mv "$UPGRADE_DIR/msaber-back/static" /app/static

    echo "清理升级包..."
    rm -rf "$PACKAGE"
    rm -rf "$UPGRADE_DIR"
fi

chown msaber:msaber -R \
    /app \
    /var/lib/nginx \
    /run/nginx \
    /var/log/nginx \
    /etc/nginx
nginx
cd /app || exit
umask "${UMASK}"
exec su-exec msaber:msaber /app/mediaSaber

# exec su-exec msaber:msaber dlv --listen=:2345 --headless=true --api-version=2 --accept-multiclient exec /app/mediaSaber
