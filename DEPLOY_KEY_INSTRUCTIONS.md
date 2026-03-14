# 一键推送至 GitHub（Zeabur 部署用）

## 1. 添加 Deploy Key（仅需一次）

1. 打开：**https://github.com/sanyueweiyang/loveme.os/settings/keys**
2. 点击 **Add deploy key**
3. **Title** 填：`zeabur-deploy`（或任意名称）
4. **Key** 粘贴下面整行（含 `ssh-ed25519` 和末尾注释）：

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJwp1DzPvfpY+x2uQmSHGXZbmx9hHAB/axDxdR0NiJwr loveme-os-zeabur-deploy
```

5. **勾选 “Allow write access”**
6. 点击 **Add key**

## 2. 执行推送

在项目根目录（loveme.os）执行：

```bash
chmod +x push-with-deploy-key.sh
./push-with-deploy-key.sh
```

或直接：

```bash
GIT_SSH_COMMAND="ssh -i $(pwd)/.ssh-deploy/id_ed25519 -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes" git push origin main
```

## 3. Zeabur 配置（推送成功后）

- **Root Directory**：`server`
- **环境变量**：
  - `DATABASE_URL`：例如 `file:./prisma/dev.db`（Zeabur 若用 SQLite 持久化卷，按控制台提示填）
  - `ALLOWED_ORIGINS`（可选）：若后端需限制 CORS，填前端域名，如 `https://xxx.lovable.app`；当前后端已放开 CORS，可不填。
