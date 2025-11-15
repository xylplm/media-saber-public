#!/bin/bash

# ----------------------------------
# 参数解析
# ----------------------------------
REPO_DIR=""
JSON_FILE=""
VERSION=""

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

if [[ -z "$REPO_DIR" || -z "$JSON_FILE" || -z "$VERSION" ]]; then
  echo "Usage: $0 -r <repo_dir> -f <json_file> -v <version>"
  exit 1
fi

ROOT_DIR=$(pwd)

# ----------------------------------
# 进入仓库
# ----------------------------------
cd "$REPO_DIR" || { echo "仓库目录不存在：$REPO_DIR"; exit 1; }

# ----------------------------------
# 获取最后一个 commit
# ----------------------------------
if [ -f "$ROOT_DIR/$JSON_FILE" ] && [ -s "$ROOT_DIR/$JSON_FILE" ]; then
    LAST_COMMIT=$(jq -r '.[-1].items[-1].commit' "$ROOT_DIR/$JSON_FILE")
    [ "$LAST_COMMIT" = "null" ] && LAST_COMMIT=""
    echo "获取到最后一个 commit: $LAST_COMMIT"
else
    LAST_COMMIT=""
    echo "无历史版本记录"
fi

# ----------------------------------
# 获取提交日志（使用 NULL 分隔确保安全）
# ----------------------------------
LOG_EXCLUDE_PATTERN="^\(chore:\|fix\|fix: 修复前端佬的 bug\)$"
NUM_LOGS=20

if [ -z "$LAST_COMMIT" ]; then
    RANGE_OPT="-n $NUM_LOGS"
    echo "无版本记录，获取最近 $NUM_LOGS 条提交"
else
    RANGE_OPT="$LAST_COMMIT..HEAD"
    echo "获取 $LAST_COMMIT 到 HEAD 的提交"
fi

# 使用 git log 获取提交记录，最新的在前
# 格式：哈希 作者 日期 主题
MESSAGE_SEPARATOR="lovebigbaby%x09lovebigbaby"
GIT_LOG_DATA=$(git log --no-merges $RANGE_OPT --invert-grep --grep="$LOG_EXCLUDE_PATTERN" --pretty=format:"%H$MESSAGE_SEPARATOR%an$MESSAGE_SEPARATOR%ad$MESSAGE_SEPARATOR%s" --date=format:'%Y-%m-%d %H:%M:%S')

# 使用 jq 将输入转换为 JSON 数组，并反转顺序
ITEMS=$(echo "$GIT_LOG_DATA" | jq -R '
  [
    inputs | split("lovebigbaby\tlovebigbaby") | {
      hash: .[0],
      author: .[1],
      date: .[2],
      message: .[3]
    }
  ]
')

# ITEMS 反转
ITEMS=$(echo "$ITEMS" | jq -s 'reverse')

NEW_BLOCK=$(jq -n --arg v "$VERSION" --argjson items "$ITEMS" \
  '{version:$v, items:$items}')

cd "$ROOT_DIR" || exit 1

# ----------------------------------
# 写入 JSON
# ----------------------------------
if [ ! -f "$JSON_FILE" ] || [ ! -s "$JSON_FILE" ]; then
    echo "[$NEW_BLOCK]" > "$JSON_FILE"
else
    jq "[ $NEW_BLOCK ] + . | .[:10]" "$JSON_FILE" > "$JSON_FILE.tmp"
    mv "$JSON_FILE.tmp" "$JSON_FILE"
fi

# 再裁剪一次保证 10 条以内
jq '.[-10:]' "$JSON_FILE" > "$JSON_FILE.tmp"
mv "$JSON_FILE.tmp" "$JSON_FILE"

# ----------------------------------
# Git 提交
# ----------------------------------
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

MAX_RETRIES=10
RETRY=0
SLEEP_SECONDS=5  # 每次重试前休眠时间，可根据需要调整

git add "$JSON_FILE"
git commit -m "Update version: $VERSION"

while [ $RETRY -lt $MAX_RETRIES ]; do
  # 尝试推送
  if git push origin main --force-with-lease; then
    echo "版本 $VERSION 已写入 $JSON_FILE，并 Push 成功！"
    exit 0
  else
    echo "Push 失败，尝试更新本地分支并重试..."
    git fetch origin main
    git rebase origin/main
    RETRY=$((RETRY+1))
    echo "休眠 $SLEEP_SECONDS 秒后重试..."
    sleep $SLEEP_SECONDS
  fi
done
echo "Push 多次失败，请手动检查冲突。"
exit 1
