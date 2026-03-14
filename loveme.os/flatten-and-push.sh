#!/bin/bash
# 暴力搜救：把 package.json 所在目录的全部内容搬到当前（repo 根）目录
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
# 若当前目录没有 server 子目录但有 package.json，说明可能在 server 里，先回到上级
if [ ! -d "server" ] && [ -f "package.json" ] && [ -d "src" ]; then
  cd .. && ROOT="$(pwd)" && cd "$ROOT"
fi

# 优先选子目录里的 package.json；若存在 server/package.json 则强制用 server
if [ -f "./server/package.json" ]; then
  CODE_HOME="./server"
else
  CODE_HOME=$(find . -name "package.json" -not -path "*/node_modules/*" | while read f; do
    d=$(dirname "$f"); [ "$d" != "." ] && echo "$d" && break
  done | head -n 1)
fi

if [ -n "$CODE_HOME" ] && [ "$CODE_HOME" != "." ]; then
    echo "发现代码在 $CODE_HOME，正在强制搬家到根目录..."
    mv "$CODE_HOME"/* . 2>/dev/null || true
    # 只移动隐藏文件，排除 . 和 ..
    for f in "$CODE_HOME"/.[!.]*; do
        [ -e "$f" ] && mv "$f" . 2>/dev/null || true
    done
    # 确保 Dockerfile / zbpack.json 一定在根目录
    [ -f "$CODE_HOME/Dockerfile" ] && cp "$CODE_HOME/Dockerfile" . 2>/dev/null || true
    [ -f "$CODE_HOME/zbpack.json" ] && cp "$CODE_HOME/zbpack.json" . 2>/dev/null || true
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
