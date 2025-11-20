#!/bin/bash

# 告诉 bash，如果任何命令（非条件判断）失败，立即退出
set -e

PACKAGE="/app/mediaSaber-upgrade.tar.gz"
UPGRADE_DIR="/app/mediaSaber-upgrade"

# 封装一个错误退出的函数
exit_with_error() {
    echo "错误: $1" >&2
    exit 1
}

# 检查升级包是否存在
if [ ! -f "$PACKAGE" ]; then
    echo "错误：升级包 $PACKAGE 未找到。" >&2
    exit 1
fi

echo "开始解压升级包..."
mkdir -p "$UPGRADE_DIR" || exit_with_error "创建升级目录 $UPGRADE_DIR 失败。"
echo "解压目录创建成功。"

tar -zxf "$PACKAGE" -C "$UPGRADE_DIR" || exit_with_error "解压 $PACKAGE 失败。"
echo "升级包解压成功。"


echo "替换后端..."
cp "$UPGRADE_DIR/msaber-back/mediaSaber" /app/mediaSaber || exit_with_error "复制后端 /app/mediaSaber 失败。"
chmod +x /app/mediaSaber || exit_with_error "为 /app/mediaSaber 添加执行权限失败。"
echo "后端替换成功。"

echo "替换前端..."
rm -rf /app/front || exit_with_error "删除旧前端 /app/front 失败。"
mv "$UPGRADE_DIR/msaber-front" /app/front || exit_with_error "移动新前端到 /app/front 失败。"
echo "前端替换成功。"

echo "替换配置..."
rm -rf /app/etc || exit_with_error "删除旧配置 /app/etc 失败。"
mv "$UPGRADE_DIR/msaber-back/etc" /app/etc || exit_with_error "移动新配置到 /app/etc 失败。"
echo "配置替换成功。"

echo "替换文档..."
rm -rf /app/doc || exit_with_error "删除旧文档 /app/doc 失败。"
mv "$UPGRADE_DIR/msaber-back/doc" /app/doc || exit_with_error "移动新文档到 /app/doc 失败。"
echo "文档替换成功。"

echo "替换静态文件..."
rm -rf /app/static || exit_with_error "删除旧静态文件 /app/static 失败。"
mv "$UPGRADE_DIR/msaber-back/static" /app/static || exit_with_error "移动新静态文件到 /app/static 失败。"
echo "静态文件替换成功。"

echo "清理升级包..."
# 清理步骤失败不应导致脚本退出，只打印警告
rm -rf "$PACKAGE" || echo "警告：清理升级包 $PACKAGE 失败。" >&2
rm -rf "$UPGRADE_DIR" || echo "警告：清理升级目录 $UPGRADE_DIR 失败。" >&2
echo "清理完成。"

echo "文件替换完毕。应用已重启。"
exit 0