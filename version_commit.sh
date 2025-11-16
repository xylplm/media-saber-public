#!/bin/bash

# ----------------------------------
# Git 提交
# ----------------------------------
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

MAX_RETRIES=10
RETRY=0
SLEEP_SECONDS=5  # 每次重试前休眠时间，可根据需要调整

git add upgrade
git commit -m "update version"

while [ $RETRY -lt $MAX_RETRIES ]; do
  # 尝试推送
  if git push origin main --force-with-lease; then
    echo "push 成功"
    exit 0
  else
    echo "push 失败，尝试更新本地分支并重试..."
    git fetch origin main
    git rebase origin/main
    RETRY=$((RETRY+1))
    echo "休眠 $SLEEP_SECONDS 秒后重试..."
    sleep $SLEEP_SECONDS
  fi
done
echo "push 多次失败，请手动检查冲突。"
exit 1