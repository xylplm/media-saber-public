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
# 进入 REPO_DIR 获取提交日志
# ----------------------------------
cd "$REPO_DIR" || { echo "仓库目录不存在：$REPO_DIR"; exit 1; }

# 读取 JSON 最后一条记录的最后一个 commit
if [ -f "$ROOT_DIR/$JSON_FILE" ] && [ -s "$ROOT_DIR/$JSON_FILE" ]; then
    LAST_COMMIT=$(jq -r '.[-1].items[-1].commit' "$ROOT_DIR/$JSON_FILE")
    [ "$LAST_COMMIT" = "null" ] && LAST_COMMIT=""
    echo "获取到最后一个 commit: $LAST_COMMIT"
else
    LAST_COMMIT=""
    echo "无 commit"
fi

LOG_EXCLUDE_PATTERN="^\(chore:\|fix\|fix: 修复前端佬的 bug\)$"
NUM_LOGS=20
# 获取提交日志
if [ -z "$LAST_COMMIT" ]; then
    echo "无版本记录，获取最近 $NUM_LOGS 条提交"
    LOGS=$(git log -n $NUM_LOGS --no-merges --invert-grep --grep="$LOG_EXCLUDE_PATTERN" --pretty=format:'{"commit":"%H","author":"%an","date":"%ad","message":"%s"}' --date=iso)
else
    echo "有版本记录，获取 $LAST_COMMIT 到 HEAD 的提交"
    LOGS=$(git log "$LAST_COMMIT"..HEAD --no-merges --invert-grep --grep="$LOG_EXCLUDE_PATTERN" --pretty=format:'{"commit":"%H","author":"%an","date":"%ad","message":"%s"}' --date=iso)
fi
# 调试打印
echo "==== DEBUG: LOGS ===="
echo $LOGS
echo "==== END DEBUG ===="

cd "$ROOT_DIR" || exit 1

# ----------------------------------
# 生成新版本块
# ----------------------------------
if [ -z "$LOGS" ]; then
    NEW_BLOCK=$(jq -n --arg v "$VERSION" '{version:$v, items:[]}')
else
    NEW_BLOCK=$(jq -n --arg v "$VERSION" --argjson items "$(echo "$LOGS" | jq -s 'reverse')" '{version:$v, items:$items}')
fi

# ----------------------------------
# 写入 JSON 文件（插入首位 + 保留最新 10 个版本）
# ----------------------------------
if [ ! -f "$JSON_FILE" ] || [ ! -s "$JSON_FILE" ]; then
    echo "[$NEW_BLOCK]" > "$JSON_FILE"
else
    jq "[ $NEW_BLOCK ] + . | .[:10]" "$JSON_FILE" > "$JSON_FILE.tmp"
    mv "$JSON_FILE.tmp" "$JSON_FILE"
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
git fetch origin main
git rebase origin/main
git push origin main --force-with-lease

echo "版本 $VERSION 已写入 $JSON_FILE 并推送成功"
