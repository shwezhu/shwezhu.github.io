---
title: CNAME 指向 GitHub Pages 问题
date: 2024-04-07 21:43:22
categories:
 - build website
 - networking
tags:
 - build website
 - networking
---


我正使用 github pages 自定义域名功能, 然后我为我的域名yorforger.cc 添加了一个 CNAME 记录即: blog.yorforger.cc -> shwezhu.github.io

然后我在 GitHub pages 的自定义域名页面填入 blog.yorforger.cc, 然后一切工作正常, 我可以通过 blog.yorforger.cc 来访问我部署在 GitHub pages 上的博客. 

我还有个域名 yorblogger.top 托管在了 Cloudflare, 我就想 是不是 我可以给它添加一个 CNAME 记录, 比如: blog.yorblogger.top -> blog.yorforger.cc 

这样当我访问 blog.yorblogger.top, DNS 服务器会去查询  blog.yorforger.cc 的地址, 最后找到 shwezhu.github.io 然后访问我的博客, 但是当我尝试在浏览器访问blog.yorblogger.top  的时候, github 提示 404: There isn't a GitHub Pages site here. 

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/04/7f104bcc413e691178004d8951742056.jpg)

这是为什么呢? 原因很简单: 

GitHub Pages 允许您将站点关联到一个自定义域名。然而，GitHub Pages 的后端服务是基于 HTTP Host 头来路由请求到正确的站点的。当您尝试通过一个不是直接在 GitHub Pages 配置中设置的域名访问时（在这种情况下是 blog.yorblogger.top），GitHub 服务器无法找到匹配的站点，因为它期望 Host 头是 blog.yorforger.cc。