#!/bin/bash
# 暴力搜救：把 package.json 所在目录的全部内容搬到当前（repo 根）目录
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

CODE_HOME=$(find . -name "package.json" -not -path "*/node_modules/*" | head -n 1 | xargs dirname 2>/dev/null || true)

if [ -n "$CODE_HOME" ] && [ "$CODE_HOME" != "." ]; then
    echo "发现代码在 $CODE_HOME，正在强制搬家到根目录..."
    mv "$CODE_HOME"/* . 2>/dev/null || true
    # 只移动隐藏文件，排除 . 和 ..
    for f in "$CODE_HOME"/.[!.]*; do
        [ -e "$f" ] && mv "$f" . 2>/dev/null || true
    done
    rm -rf "$CODE_HOME"
fi

if [ ! -f "Dockerfile" ]; then
    echo "警告：根目录依然没有 Dockerfile！正在全盘深挖..."
    find .. -name "Dockerfile" -exec mv {} . \; 2>/dev/null || true
fi

git add -A
git status
git commit -m "STRICT: Flatten directory structure and expose Dockerfile" || true
GIT_SSH_COMMAND="ssh -i $ROOT/.ssh-deploy/id_ed25519 -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes" git push -f origin main 2>/dev/null || git push -f origin main
