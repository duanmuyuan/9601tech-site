# 9601tech-site

深圳市玖陆零壹科技有限责任公司官网(静态站,单文件 `index.html`)。

- 用途:企业官网(Apple 企业开发者账号审核要求的"公开、正常运行的组织官网")。
- 域名:9601tech.com(根域,`CNAME` 指定)。

## 部署

纯静态,无构建步骤。

### 现状(备案通过前):GitHub Pages
- 仓库开 Pages「Deploy from branch = main / 根目录」,`git push` 即发布。
- 海外托管、免 ICP 备案、自带 HTTPS —— 这正是备案在审期间官网要能访问的关键。
- `.nojekyll` 必须保留:否则 Jekyll 会忽略 `.well-known/`,导致 Universal Links 的
  AASA(`/.well-known/apple-app-site-association`)404。

### 备案通过后(可选):火山 ECS + Nginx
- `9601tech.com` ICP 备案通过后,若要迁到境内火山 ECS,用 `./deploy.sh [dev|prod]`
  (rsync 全站 + 备份/回滚),配 `nginx.conf.example`,`./rollback.sh` 回滚。
- 🔴 红线:用 9601tech 独立主体的 SSL 证书 + 独立 server_name,勿复用虾米资源。
- ⚠️ 备案通过前别把根域指回境内 ECS(会被 ISP 拦、把官网搞挂)。

## Universal Links
`.well-known/apple-app-site-association` 承载主域名深链(paths `/t/*` `/u/*`)。
拿到 Apple Team ID 后把文件里的 `TEAMID` 占位替换掉。详见 duile-wiki `deployment.md §6.5`。
