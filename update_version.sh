#!/bin/bash

# ----------------------------------
# 参数解析
# ----------------------------------
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <json_file> <version>"
    exit 1
fi

JSON_FILE="$1"     # 如 ./upgrade/dev.json
VERSION="$2"       # 如 DEV_202511151249
REPO_DIR="msaber-back"
NUM_INITIAL_LOGS=10

ROOT_DIR=$(pwd)

# ----------------------------------
# 进入 msaber-back 获取提交日志
# ----------------------------------
cd "$REPO_DIR" || { echo "仓库目录不存在：$REPO_DIR"; exit 1; }

# 读取 JSON 最后一条记录的最后一个 commit
if [ -f "$ROOT_DIR/$JSON_FILE" ] && [ -s "$ROOT_DIR/$JSON_FILE" ]; then
    LAST_COMMIT=$(jq -r '.[-1].items[-1].commit' "$ROOT_DIR/$JSON_FILE")
    [ "$LAST_COMMIT" = "null" ] && LAST_COMMIT=""
else
    LAST_COMMIT=""
fi

# 获取提交日志
if [ -z "$LAST_COMMIT" ]; then
    LOGS=$(git log -n $NUM_INITIAL_LOGS --pretty=format:'{"commit":"%H","author":"%an","date":"%ad","message":"%s"}' --date=iso)
else
    LOGS=$(git log "$LAST_COMMIT"..HEAD --pretty=format:'{"commit":"%H","author":"%an","date":"%ad","message":"%s"}' --date=iso)
fi

echo "$LOGS"

cd "$ROOT_DIR" || exit 1

# 若无新增提交则退出
if [ -z "$LOGS" ]; then
    echo "没有新增提交"
    exit 0
fi

# ----------------------------------
# 生成新版本块
# ----------------------------------
NEW_BLOCK=$(printf '{ "version": "%s", "items": [ %s ] }' "$VERSION" "$(echo "$LOGS" | sed '$!s/$/,/')")

# ----------------------------------
# 写入 JSON 文件
# ----------------------------------
if [ ! -f "$JSON_FILE" ] || [ ! -s "$JSON_FILE" ]; then
    # 创建新 JSON
    echo "[ $NEW_BLOCK ]" > "$JSON_FILE"
else
    # 追加
    tmp=$(mktemp)
    head -n -1 "$JSON_FILE" > "$tmp"
    echo "  ,$NEW_BLOCK" >> "$tmp"
    echo "]" >> "$tmp"
    mv "$tmp" "$JSON_FILE"
fi

echo "裁剪 JSON，仅保留最新 10 个版本..."

# 只保留最新 10 条版本记录
jq '.[-10:]' "$JSON_FILE" > "$JSON_FILE.tmp"
mv "$JSON_FILE.tmp" "$JSON_FILE"

# ----------------------------------
# Git 提交（项目根目录）
# ----------------------------------
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

git add "$JSON_FILE"
git commit -m "Update version: $VERSION"
git push origin main

echo "版本 $VERSION 已写入 $JSON_FILE 并推送成功"
