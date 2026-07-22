#!/bin/bash
# 9601tech.com 官网部署脚本(★ 备案通过后启用 ★)
#
# 现状:官网跑在 GitHub Pages(海外、免备案、自带 HTTPS),git push 即发布。
# 本脚本供 9601tech.com ICP 备案通过、决定把官网迁到火山境内 ECS + Nginx 后使用。
# 备案通过前不要用:境内 ECS 服务未备案域名会被 ISP 拦截,且会把官网(备案/Apple
# 审核要看的"正常运行组织官网")搞挂。
#
# 🔴 红线(独立主体):9601tech 用自己的 SSL 证书 + 独立 server_name,
#    严禁复用虾米 *.zzss.fun 证书或同一 Nginx server block。
#
# 用法:./deploy.sh [dev|prod]
#   服务器可用环境变量覆盖:DEPLOY_SERVER=root@x.x.x.x ./deploy.sh prod
set -e

ENV="${1:-dev}"
LOCAL_DIR="$(cd "$(dirname "$0")" && pwd)"

case "$ENV" in
    dev)
        # DEV ECS(与 duile-server/admin/h5 同机)。备案后 dev 建议用子域名。
        SERVER="${DEPLOY_SERVER:-root@14.103.36.7}"
        SITE_URL="https://site-dev.9601tech.com"
        ;;
    prod)
        # ⚠️ PROD ECS IP 待填(或用 DEPLOY_SERVER 覆盖)
        SERVER="${DEPLOY_SERVER:-root@PROD-ECS-IP-待填}"
        SITE_URL="https://9601tech.com"
        ;;
    *)
        echo "用法: $0 [dev|prod]"
        exit 1
        ;;
esac

REMOTE_DIR="/var/www/9601tech-site"
BACKUP_DIR="/var/www/backups/9601tech-site"

echo "=== 9601tech.com 官网部署 [$ENV] → $SERVER ==="

echo "=== 1. 备份当前版本(若存在) ==="
TS=$(date +%Y%m%d_%H%M%S)
ssh "$SERVER" "mkdir -p '$REMOTE_DIR' '$BACKUP_DIR'; \
  if [ -n \"\$(ls -A '$REMOTE_DIR' 2>/dev/null)\" ]; then \
    cp -r '$REMOTE_DIR' '$BACKUP_DIR/$TS' && echo '备份完成: $BACKUP_DIR/$TS'; \
  else echo '首次部署,无需备份'; fi"

echo "=== 2. 同步全站(含 .well-known/ 的 AASA;排除 git/dev/GitHub-Pages 专用文件) ==="
# rsync 全站镜像 --delete 保证服务器目录与本仓一致。
# 排除:.git .gitignore README.md .DS_Store;CNAME/.nojekyll 是 GitHub Pages 专用,ECS 用不到。
rsync -az --delete \
    --exclude='.git/' \
    --exclude='.gitignore' \
    --exclude='README.md' \
    --exclude='CNAME' \
    --exclude='.nojekyll' \
    --exclude='.DS_Store' \
    --exclude='deploy.sh' \
    --exclude='rollback.sh' \
    --exclude='nginx.conf.example' \
    "$LOCAL_DIR/" "$SERVER:$REMOTE_DIR/"

echo "=== 3. 清理旧备份(保留最近 5 个) ==="
ssh "$SERVER" "cd '$BACKUP_DIR' && ls -t | tail -n +6 | xargs -r rm -rf"

echo "=== 部署完成 [$ENV] ==="
echo "访问: $SITE_URL"
echo "AASA 自检: curl -sI $SITE_URL/.well-known/apple-app-site-association  # 期望 200"
