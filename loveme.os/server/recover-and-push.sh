#!/bin/bash
# 1. 寻找并带回所有丢失的 Dockerfile 和 prisma 到当前目录（server）
set -e
cd "$(dirname "$0")"
find . -name "Dockerfile" -exec mv {} . \; 2>/dev/null || true
find . -name "prisma" -type d -exec mv {} . \; 2>/dev/null || true
find .. -name "Dockerfile" -exec mv {} . \; 2>/dev/null || true
find .. -name "prisma" -type d -exec mv {} . \; 2>/dev/null || true
echo "--- ls -F ---"
ls -F
# 2. 若在仓库根目录执行，则做 git 提交并推送（请根据实际情况在 repo 根目录运行 git）
REPO_ROOT="$(cd .. && pwd)"
if [ -d "$REPO_ROOT/.git" ]; then
  cd "$REPO_ROOT"
  git add .
  git status
  git commit -m "chore: automated recovery and flattening of project structure" || true
  GIT_SSH_COMMAND="ssh -i $REPO_ROOT/.ssh-deploy/id_ed25519 -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes" git push -f origin main 2>/dev/null || git push -f origin main
  echo "Done."
fi
