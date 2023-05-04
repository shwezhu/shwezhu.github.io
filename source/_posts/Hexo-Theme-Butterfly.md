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

nav#nav
  span#blog_name
    a#site-name(href=url_for('/')) #[=config.title]
    
  #menus
    if (theme.algolia_search.enable || theme.local_search.enable)
      #search-button
        a.site-page.social-icon.search
          i.fas.fa-search.fa-fw
          span=' '+_p('search.title')
  !=partial('includes/header/menu_item', {}, {cache: true})
  #nav-right
    if (theme.algolia_search.enable || theme.local_search.enable)
      #search-button
        a.site-page.social-icon.search
          i.fas.fa-search.fa-fw
          span=' '+_p('search.title')
    #toggle-menu
      a.site-page
        i.fas.fa-bars.fa-fw
      #toggle-menu
        a.site-page
          i.fas.fa-bars.fa-fw
```

原本的:

```
nav#nav
  span#blog-info
    a(href=url_for('/') title=config.title)
      if theme.nav.logo
        img.site-icon(src=url_for(theme.nav.logo))
      if theme.nav.display_title
        span.site-name=config.title
    
  #menus
    if (theme.algolia_search.enable || theme.local_search.enable || theme.docsearch.enable)
      #search-button
        a.site-page.social-icon.search(href="javascript:void(0);")
          i.fas.fa-search.fa-fw
          span=' '+_p('search.title')
    !=partial('includes/header/menu_item', {}, {cache: true})

    #toggle-menu
      a.site-page(href="javascript:void(0);")
        i.fas.fa-bars.fa-fw

```

