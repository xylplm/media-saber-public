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

# --- 重启逻辑开始 ---

echo "重载 Nginx 配置..."
# 捕获 Nginx reload 的输出 (标准错误和标准输出)
nginx_output=$(nginx -s reload 2>&1)
# 检查上一条命令 (nginx -s reload) 的退出码
if [ $? -ne 0 ]; then
    # 如果失败，打印 Nginx 提供的具体错误信息并退出
    exit_with_error "Nginx 重载 (reload) 失败。Nginx 输出: $nginx_output"
fi
echo "Nginx 配置已重载。"

# 停止旧应用。
# || true 确保在应用未运行时脚本不会因此失败。
pkill -9 /app/mediaSaber || true
echo "旧应用已停止。"

sleep 1

# 启动新应用。
# 使用 & 在后台运行，并将输出重定向到 /dev/null
/app/mediaSaber >/dev/null 2>&1 &
echo "新应用已启动（后台）。"

# 等待3秒，确保Go应用有足够时间启动
echo "等待3秒让应用启动..."
sleep 3

# [新增] 检查应用是否真的在运行
# pgrep -f 会查找包含 "/app/mediaSaber" 的进程
# >/dev/null 会丢弃 pgrep 的正常输出（进程ID）
if ! pgrep -f /app/mediaSaber > /dev/null; then
    # 如果 pgrep 找不到进程（异常），则打印警告
    echo "警告：应用 /app/mediaSaber 启动 3 秒后，未检测到正在运行的进程。请检查应用日志。" >&2
fi
# --- 重启逻辑结束 ---

echo "清理升级包..."
# 清理步骤失败不应导致脚本退出，只打印警告
rm -rf "$PACKAGE" || echo "警告：清理升级包 $PACKAGE 失败。" >&2
rm -rf "$UPGRADE_DIR" || echo "警告：清理升级目录 $UPGRADE_DIR 失败。" >&2
echo "清理完成。"

echo "文件替换完毕。应用已重启。"
exit 0