# 藏书阁 · open-bookshelf 技能仓库

> 本仓库是「藏书阁」技能的**完整主副本**：技能说明 + 启动脚本 + 全部书架资产（11 册 PDF + 13 张封面 + 在线作业卡）。任何 AI / 任何环境 clone 本仓库即可完整接手维护用户的个人学习书架。

---

## 1. 这是什么

用户（华工 MEM 学生）的个人学习卡片库书架，形似读书 App 的书墙：

- **线上书架地址**：`https://xiayi3642-spec.github.io/bookshelf/`（手机 / 平板 / 电脑均可访问）
- **线上书架仓库**：`https://github.com/xiayi3642-spec/bookshelf`（GitHub Pages 部署源，bookshelf/ 内容单独管理）
- **本仓库（open-bookshelf）**：技能完整副本，含维护所需的全部资产与说明

## 2. 目录结构

```
open-bookshelf/
├── SKILL.md                 # 技能使用说明（AI 读这个就能干活）
├── scripts/
│   └── serve.sh             # 本地启动书架 HTTP 服务（端口 8931）
└── assets/
    └── bookshelf/           # 书架主副本（与线上 bookshelf 仓库内容一致）
        ├── index.html       # 书墙页面（PDF.js 阅读器 + 搜索 + 分类 + 外部链接卡）
        ├── index.json       # 书籍索引（书名/课程/封面/页数/链接）
        ├── books/           # 全部 PDF 卡片（命名：序号-课程-标题.pdf）
        ├── covers/          # 全部封面缩略图（与 PDF 同名 .png）
        └── vendor/pdfjs/    # 离线 PDF.js 阅读引擎
```

## 3. 快速开始（本地预览）

```bash
bash scripts/serve.sh        # 幂等启动，已在运行则复用
# 输出：
#   local:  http://127.0.0.1:8931
#   lan:    http://<内网IP>:8931
```

浏览器打开 `http://127.0.0.1:8931` 即可看到书墙。验证：`curl -sf http://127.0.0.1:8931/index.html` 应返回 200。

## 4. 放进书架（加书）——PDF 卡片

用户说「放进书架 / 加一本书」时：

1. 把新卡片 PDF 拷入 `assets/bookshelf/books/`，命名规范 `序号-课程-标题.pdf`，序号接现有最大号（当前最大 12）。
2. 生成封面：`pdftoppm -f 1 -l 1 -r 40 -png <pdf> /tmp/cov_<name>`，产物为 `-01.png`，改名放入 `covers/<同名>.png`；纯图片型 PDF 若 pdftoppm 失败，改用 PyMuPDF 渲染第一页。
3. 更新 `assets/bookshelf/index.json`，追加条目 `{id, title, course, desc, file, cover, date, pages, sizeMB}`。course 需与现有分组一致；新课程需在 `index.html` 的 `COURSE_ORDER` 数组追加。
4. 刷新书架页确认新卡片出现。

## 5. 放进书架——外部链接卡（点击跳转网页/飞书文档）

用户要放一段链接（如飞书作业文档）而不是 PDF 时：

1. **不需要 PDF 文件**，只需一张封面图放入 `covers/<序号-课程-标题>.png`（1080×1440 竖版为宜，可用 editorial-note-cards 技能模板生成）。
2. index.json 条目**不带 `file` 字段**，改为带 `link` 字段：`{id, title, course, desc, cover, link, date, pages:0, sizeMB:0}`。
3. index.html 已内置支持：有 `link` 的卡片显示「打开」按钮，点击封面/标题用新窗口打开链接，不进入 PDF 阅读器。
4. 刷新书架页确认卡片出现且点击可跳转。

示例（当前第 12 册即为飞书作业卡）：
```json
{
  "id": "12",
  "title": "PPT课后作业汇总",
  "course": "工程管理导论",
  "desc": "飞书在线作业 · 待老师补充例子",
  "cover": "12-工程管理导论-PPT课后作业.png",
  "link": "https://my.feishu.cn/wiki/KDr8w9py6ilaNlkBLhtctWZGncb",
  "date": "2026-10-31",
  "pages": 0,
  "sizeMB": 0
}
```

## 6. 推送更新（GitHub Pages 线上书架）

书架线上部署在 **bookshelf 仓库**（`https://github.com/xiayi3642-spec/bookshelf`），push 后约 1 分钟自动发布到 Pages。

### 方式 A：直接操作 bookshelf 仓库（推荐，线上即生效）

```bash
# 1) 拉一份线上仓库（或复用已有）
git clone https://github.com/xiayi3642-spec/bookshelf.git /tmp/bookshelf
cd /tmp/bookshelf

# 2) 用本仓库 assets/bookshelf 的内容覆盖（index.html / index.json / books/ / covers/ / vendor/）
rsync -a /path/to/open-bookshelf/assets/bookshelf/ /tmp/bookshelf/

# 3) 提交推送
git add -A
git commit -m "加书：<说明>"
git -c credential.helper=store push origin main
```

### 方式 B：在本仓库内直接维护并同步

本仓库 `assets/bookshelf/` 即线上书架内容的镜像；改完本仓库后，按方式 A 同步到 bookshelf 仓库即可。

### 推送后验证

```bash
# 1) 确认推送到达远程（本地/远程 HEAD 一致）
git fetch origin -q && git rev-parse HEAD origin/main

# 2) 轮询 Pages 线上更新（构建有延迟属正常，最多等 1-2 分钟）
curl -sf https://xiayi3642-spec.github.io/bookshelf/index.json | head
```

## 7. 凭证与安全

- GitHub 凭据存于本机 `~/.git-credentials`（权限 600），推送时用 `git -c credential.helper=store push` 自动读取。
- **严禁**把 token / 密码写入本仓库任何被 git 跟踪的文件——仓库是公开的，写入即泄露。
- 用户已授权将书架公开（GitHub Pages 公网可访问）。

## 8. 版本原则

- 同一讲 / 同一内容只保留最新版；不同内容全部保留。
- 用户明确指定保留 / 删除时以用户为准；删除前先确认。
- 云沙箱可能回滚工作区（.git 丢失、文件回退旧版），**以 GitHub 线上为权威**，本地异常时重新 clone 恢复。

## 8.1 页面排序与删除功能（2026-11-01 起）

- **排序**：书架默认按 `date` 字段**倒序**（最新在前）；筛选某课程时组内同样倒序。排序在 `index.html` 的 `filtered()` 内实现，无需改 index.json 顺序。
- **删除（页面按钮）**：每张卡片左上角有「删除」按钮 → 确认后写入 `localStorage('shelf_hidden')` 并隐藏该卡，顶部出现「已删除 N 册 · 恢复全部」提示条。**注意：这是本设备前端隐藏，不修改 index.json / 不删文件**——换设备或清缓存会重新出现；需要真正删除（从线上移除）必须改 index.json 并删对应文件后推送 bookshelf 仓库。

## 9. 封面模板参考

封面图可复用另一个技能仓库 `xiayi3642-spec/editorial-note-cards`（note card 卡片技能）的 17 种风格模板（春和景明、雪山、奶油绿油画、大阪霓虹、鎏金漩涡、冷暖交融等），或直接使用其 `scripts/html2png.mjs` 渲染 1080×1440 封面。

---

*本仓库由豆包生成并托管，用于跨 AI / 跨环境交接维护藏书阁。*
