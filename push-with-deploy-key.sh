#!/bin/bash
# 在将 .ssh-deploy/id_ed25519.pub 添加为 GitHub 仓库 Deploy Key（勾选 Write）后执行此脚本完成推送
set -e
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"
export GIT_SSH_COMMAND="ssh -i $REPO_ROOT/.ssh-deploy/id_ed25519 -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes"
git push origin main
echo "✅ 已推送到 GitHub main 分支。"
