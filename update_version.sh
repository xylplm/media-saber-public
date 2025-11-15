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

RAW_LOGS=$(git log $RANGE_OPT \
  --no-merges \
  --invert-grep \
  --grep="$LOG_EXCLUDE_PATTERN" \
  --pretty=format:'%H%x00%an%x00%ad%x00%s%x00' \
  --date=iso)

echo "==== DEBUG RAW LOGS ===="
printf "%q\n" "$RAW_LOGS"
echo "========================"

# ----------------------------------
# 使用 jq 生成标准 JSON 数组（100% 安全）
# ----------------------------------
ITEMS=$(printf "%s" "$RAW_LOGS" | \
  tr '\0' '\n' | \
  jq -Rn '
    [inputs | select(length>0) |
      split("\n") |
      {
        commit: .[0],
        author: .[1],
        date: .[2],
        message: .[3]
      }
    ] | reverse
  ')

echo "==== DEBUG ITEMS JSON ===="
echo "$ITEMS"
echo "=========================="

cd "$ROOT_DIR" || exit 1

# ----------------------------------
# 构建新版本块
# ----------------------------------
NEW_BLOCK=$(jq -n --arg v "$VERSION" --argjson items "$ITEMS" \
  '{version:$v, items:$items}')

echo "==== NEW BLOCK ===="
echo "$NEW_BLOCK"
echo "==================="

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

git add "$JSON_FILE"
git commit -m "Update version: $VERSION"
git fetch origin main
git rebase origin/main
git push origin main --force-with-lease

echo "版本 $VERSION 已写入 $JSON_FILE，并推送成功！"
