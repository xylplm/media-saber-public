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

# 判断是否有更新包
if [ -f "/app/mediaSaber-upgrade.tar.gz" ]; then
    tar -zxf /app/mediaSaber-upgrade.tar.gz -C /app/mediaSaber-upgrade
    # 替换后端二进制文件
    mv /app/mediaSaber-upgrade/msaber-back/mediaSaber /app/mediaSaber
    # 赋予 mediaSaber 执行权限
    chmod +x /app/mediaSaber
    # 替换前端文件
    rm -rf /app/front
    mv /app/mediaSaber-upgrade/msaber-front /app/front
    # 替换配置文件
    rm -rf /app/etc
    mv /app/mediaSaber-upgrade/msaber-back/etc /app/etc
    rm -rf /app/doc
    mv /app/mediaSaber-upgrade/msaber-back/doc /app/doc
    rm -rf /app/static
    mv /app/mediaSaber-upgrade/msaber-back/static /app/static
    # 删除更新包文件
    rm -rf /app/mediaSaber-upgrade.tar.gz
    rm -rf /app/mediaSaber-upgrade
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
