#!/bin/bash

# ===============================

# 参数解析

# ===============================

if [ -z "$1" ]; then
echo "Usage: $0 <json_file> [num_initial_logs]"
exit 1
fi

JSON_FILE="$1"                    # 第一个参数：JSON 文件名
NUM_INITIAL_LOGS="${2:-10}"       # 第二个参数可选，默认 10 条

# ===============================

# 配置

# ===============================

REPO_DIR="./msaber-front"          # 本地仓库目录

# ===============================

# 进入仓库

# ===============================

cd "$REPO_DIR" || { echo "仓库目录不存在"; exit 1; }

# ===============================

# 获取最后 commit id

# ===============================

if [ -f "../$JSON_FILE" ] && [ -s "../$JSON_FILE" ]; then
LAST_COMMIT=$(jq -r '.[-1].commit' "../$JSON_FILE")
if [ "$LAST_COMMIT" == "null" ]; then
LAST_COMMIT=""
fi
else
LAST_COMMIT=""
fi

# ===============================

# 获取提交日志

# ===============================

if [ -z "$LAST_COMMIT" ]; then
# 第一次运行，取最近 NUM_INITIAL_LOGS 条
LOGS=$(git log -n $NUM_INITIAL_LOGS --pretty=format:'{"commit":"%H","author":"%an","date":"%ad","message":"%s"}' --date=iso)
else
# 获取最后 commit 之后的提交
LOGS=$(git log "$LAST_COMMIT"..HEAD --pretty=format:'{"commit":"%H","author":"%an","date":"%ad","message":"%s"}' --date=iso)
fi

# 如果没有新增日志，则退出

if [ -z "$LOGS" ]; then
echo "没有新提交。"
exit 0
fi

cd .. || exit 1   # 回到项目根目录

# ===============================

# 处理 JSON

# ===============================

if [ -f "../$JSON_FILE" ] && [ -s "../$JSON_FILE" ]; then
tmp=$(mktemp)
head -n -1 "../$JSON_FILE" > "$tmp"
echo "$LOGS" | sed '$!s/$/,/' >> "$tmp"
echo "]" >> "$tmp"
mv "$tmp" "../$JSON_FILE"
else
echo "[" > "../$JSON_FILE"
echo "$LOGS" | sed '$!s/$/,/' >> "../$JSON_FILE"
echo "]" >> "../$JSON_FILE"
fi

# ===============================

# 提交并 push JSON

# ===============================

git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

git add "$JSON_FILE"
git commit -m "Update $JSON_FILE"
git push origin main

echo "Done! $JSON_FILE 已更新并推送。"
