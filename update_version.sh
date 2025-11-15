#!/bin/bash

# ----------------------------------
# 参数解析
# ----------------------------------
REPO_DIR="" # 如 msaber-back
JSON_FILE="" # 如 ./upgrade/dev.json
VERSION="" # 如 DEV_202511151249

# 参数解析
while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--repo-dir)
      REPO_DIR="$2"
      shift 2
      ;;
    -f|--file)
      JSON_FILE="$2"
      shift 2
      ;;
    -v|--version)
      VERSION="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# 必填校验
if [[ -z "$REPO_DIR" || -z "$JSON_FILE" || -z "$VERSION" ]]; then
  echo "Usage: $0 -r <repo_dir> -f <json_file> -v <version>"
  exit 1
fi

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

LOG_IGNORES = "^\(fix\|fix: 修复前端佬的 bug\|chore:\)$"

# 获取提交日志（去除含 chore: 关键字的日志、merge 日志）
if [ -z "$LAST_COMMIT" ]; then
    echo "无版本记录，获取最近 10 条提交"
    LOGS=$(git log -n 10 --no-merges --invert-grep --grep="$LOG_IGNORES" --pretty=format:'{"commit":"%H","author":"%an","date":"%ad","message":"%s"}' --date=iso)
else
    echo "有版本记录，获取 $LAST_COMMIT 到 HEAD 的提交"
    LOGS=$(git log "$LAST_COMMIT"..HEAD --no-merges --invert-grep --grep="$LOG_IGNORES" --pretty=format:'{"commit":"%H","author":"%an","date":"%ad","message":"%s"}' --date=iso)
fi

echo "$LOGS"

cd "$ROOT_DIR" || exit 1

# ----------------------------------
# 生成新版本块
# ----------------------------------
if [ -z "$LOGS" ]; then
    echo "没有新增提交"
  NEW_BLOCK=$(printf '{ "version": "%s", "items": [] }' "$VERSION")
else
  NEW_BLOCK=$(printf '{ "version": "%s", "items": [ %s ] }' "$VERSION" "$(echo "$LOGS" | sed '$!s/$/,/')")
fi

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
