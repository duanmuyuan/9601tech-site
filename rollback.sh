#!/bin/bash
# 9601tech.com 官网回滚脚本(配合 deploy.sh 用)
# 用法:./rollback.sh [dev|prod] [备份时间戳]
#   不传时间戳则列出可用备份并回滚到最近一个(需确认)。
set -e

ENV="${1:-dev}"
BACKUP_VERSION="$2"

case "$ENV" in
    dev)
        SERVER="${DEPLOY_SERVER:-root@14.103.36.7}"
        SITE_URL="https://site-dev.9601tech.com"
        ;;
    prod)
        SERVER="${DEPLOY_SERVER:-root@PROD-ECS-IP-待填}"
        SITE_URL="https://9601tech.com"
        ;;
    *)
        echo "用法: $0 [dev|prod] [备份时间戳]"
        exit 1
        ;;
esac

REMOTE_DIR="/var/www/9601tech-site"
BACKUP_DIR="/var/www/backups/9601tech-site"

echo "=== 9601tech.com 官网回滚 [$ENV] ==="

if [ -z "$BACKUP_VERSION" ]; then
    echo "可用备份:"
    ssh "$SERVER" "ls -t '$BACKUP_DIR' 2>/dev/null"
    echo ""
    BACKUP_VERSION=$(ssh "$SERVER" "ls -t '$BACKUP_DIR' 2>/dev/null | head -1")
    if [ -z "$BACKUP_VERSION" ]; then
        echo "错误: 没有可用的备份"
        exit 1
    fi
    echo "将回滚到最近备份: $BACKUP_VERSION"
    read -p "确认回滚? (y/N) " confirm
    [ "$confirm" != "y" ] && echo "已取消" && exit 0
fi

echo "=== 回滚到: $BACKUP_VERSION ==="
ssh "$SERVER" "rm -rf '$REMOTE_DIR'/* && cp -r '$BACKUP_DIR/$BACKUP_VERSION/.' '$REMOTE_DIR/'"

echo "=== 回滚完成 [$ENV] ==="
echo "访问: $SITE_URL"
