---
name: open-bookshelf
description: "打开和维护用户个人学习书架（书墙 HTML：封面网格 + PDF.js 在线阅读 + 下载 PDF）。当用户说「打开书架 / 我的书架 / 学习书架 / 读书架 / 看我的卡片 / 打开学习卡片」或书架打不开、要加书（「放进书架 / 加一本书 / 书架里加」）时使用。书架资产主副本在本技能 assets/bookshelf/（index.html + books/*.pdf + covers/ + vendor/pdfjs/ + index.json），通过 HTTP 服务供手机/平板/电脑浏览器访问。"
---

# 打开书架 / 维护书架

书架 = 用户个人学习卡片库（HTML 书墙：封面网格、PDF.js 在线阅读、下载、阅读进度记忆）。
资产主副本：`assets/bookshelf/`（相对本 SKILL.md）。**以后加书、改索引都在这里改。**

## 打开书架

1. 运行 `bash scripts/serve.sh`（默认端口 8931；已运行则直接复用）。
2. `curl -sf http://127.0.0.1:8931/index.html` 确认返回 200。
3. 用浏览器打开 `http://127.0.0.1:8931` 验证书架正常渲染（封面、分组、搜索框、阅读器可用）。
4. 向用户返回访问地址（serve.sh 会打印）：
   - 本机：`http://127.0.0.1:8931`
   - 同一内网设备：`http://<内网IP>:8931`
   - 外部设备（手机流量/公网）：当前环境为内网沙箱，若无法直接访问，说明需要把书架放到有公网地址的云电脑（直接拷贝 `assets/bookshelf/` 或使用已打包 zip），或配置内网穿透后我再返回新地址。不要假装外部可访问。

## 放进书架（加书）

用户说「放进书架 / 加一本书」时：

1. 把新卡片 PDF 拷入 `assets/bookshelf/books/`，命名规范：`序号-课程-标题.pdf`（序号接现有最大号）。
2. 生成封面：`pdftoppm -f 1 -l 1 -r 40 -png <pdf> /tmp/cov_<name>`，输出文件后缀为 `-01.png`，改名为 `covers/<同名>.png` 放入 `covers/`；纯图片型 PDF 若 pdftoppm 失败，改用 PyMuPDF 渲染第一页。
3. 更新 `assets/bookshelf/index.json`，按既有格式追加：`{id, title, course, desc, file, cover, date, pages, sizeMB}`；course 需与现有分组一致，新课程需在 `index.html` 的 `COURSE_ORDER` 中追加。
4. 刷新书架页，确认新卡片出现。

## 版本原则

同一讲/同一内容只保留最新版；不同内容全部保留。用户明确指定保留/删除时以用户为准。删除前先确认。
