#!/bin/bash

envsubst '${MS_PORT}' < /etc/nginx/nginx.template.conf > /etc/nginx/nginx.conf
groupmod -o -g "${PGID}" msaber
usermod -o -u "${PUID}" msaber

# 判断当前目录下是否存在名为 mediaSaber-new 的二进制文件
if [ -f "/app/mediaSaber-new" ]; then
    # 如果存在，则用它覆盖 mediaSaber
    mv /app/mediaSaber-new /app/mediaSaber
    # 赋予 mediaSaber 执行权限
    chmod +x /app/mediaSaber
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
