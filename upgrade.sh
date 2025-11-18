#!/bin/bash

# 告诉 bash，如果任何命令失败，立即退出
set -e

PACKAGE="/app/mediaSaber-upgrade.tar.gz"
UPGRADE_DIR="/app/mediaSaber-upgrade"

# 检查升级包是否存在
if [ ! -f "$PACKAGE" ]; then
    echo "升级包 $PACKAGE 未找到。" >&2
    exit 1
fi

echo "开始解压升级包..."
mkdir -p "$UPGRADE_DIR"
tar -zxf "$PACKAGE" -C "$UPGRADE_DIR"

echo "停止 Nginx ..."
# 停止 Nginx。应用(mediaSaber)将由Go程序自己退出。
pkill -9 nginx || true
sleep 1 # 等待 nginx 释放

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

echo "文件替换完毕。应用将自动重启。"
exit 0