---
title: "Hexo Butterfly主题修改"
date: 2023-05-04 10:30:30
categories:
  - Build Website
  - Hexo
tags:
  - Hexo
---

### 安装主题

在博客根目录下执行, 

```shell
git clone -b master https://github.com/jerryc127/hexo-theme-butterfly.git themes/butterfly
```

修改 Hexo 根目录下的` _config.yml`，把主题改为 butterfly:

```yaml
theme: butterfly
```

如果你没有 pug 以及 stylus 的渲染器，请下载安装：

```shell
npm install hexo-renderer-pug hexo-renderer-stylus --save
```

### 禁止显示首页图片

修改主题配置文件, 

```yaml
# Disable all banner image
disable_top_img: true
```

### 修改头像

修改主题配置文件, 把你的图片拷贝到`themes/butterfly/source/img/`, 

```yaml
# Favicon（網站圖標）
favicon: /img/favicon.png

# Avatar (頭像)
avatar:
  img: /img/favicon.png
  effect: false
```

### 插入YouTube视频

```shell
{% youtube video_id %}
```

注意, YouTube视频的ID即点即视频下方的分享按钮, 如`https://youtu.be/F_dGEjzRG_Y`的ID就是`F_dGEjzRG_Y`

{%  youtube F_dGEjzRG_Y %}

### 插入 Gist

```shell
{% gist gist_id %}
```

这是Gist的链接`https://gist.github.com/shwezhu/d2fa89616d8d9380e6ba66eb59920ed0`, ID即是最后那段, 即`d2fa89616d8d9380e6ba66eb59920ed0`

{% gist d2fa89616d8d9380e6ba66eb59920ed0 %}

### 使用Utterances评论

首先先在Github安装Utterances, 然后授权一个仓库即可, 具体过程可谷歌, 嫌麻烦可以用这个教程, 这个用的是giscus: [hexo-butterfly主题-giscus评论系统设置 - 知乎](https://zhuanlan.zhihu.com/p/603658639)

找到主题文件的对应参数, 设置如下(不用设置站点配置文件)

```yaml
comments:
  # Up to two comments system, the first will be shown as default
  Choose: Utterances
  use: Utterances
  
# utterances
utterances:
  enabled: true
  repo: shwezhu/shwezhu.github.io
  issue_term: url
  label: Comment
  theme: github-light
```

### 字数统计

```yaml
# wordcount (字數統計)
# see https://butterfly.js.org/posts/ceeb73f/#字數統計
wordcount:
  enable: true
  post_wordcount: true
  min2read: true
  total_wordcount: true
```

### 音乐播放器

[Butterfly添加全局吸底Aplayer教程 | Butterfly](https://butterfly.js.org/posts/507c070f/)
