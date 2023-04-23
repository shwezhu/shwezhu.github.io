---
title: Hexo with NexT
date: 2023-04-18 20:02:06
categories:
  - Build Website
  - Hexo
tags:
  - Hexo
---

# 1. 安装NexT

```shell
$ cd your-hexo-site
$ git clone https://github.com/iissnan/hexo-theme-next themes/next
```

你也可以使用我在GitHub的备份, 即直接复制`themes`文件夹替换博客根目录`themes`文件,但这样你还要把根目录下的配置文件`_config.yml`改成我的内容, 这样, 我们的博客样式就一样了.

# 2. 修改主题和添加社交账号
修改文件`themes/next/_config.yml`:

```shell
#Schemes
#scheme: Muse
#scheme: Mist
scheme: Pisces
#scheme: Gemini

# Social Links
social:
  GitHub: https://github.com/shwezhu || fab fa-github
  E-Mail: mailto:shaowenzhu@dal.ca || fa fa-envelope
  Twitter: https://twitter.com/shwezhu || fab fa-twitter
```

# 3. 侧边栏显示当前浏览进度
打开 `themes/next/_config.yml` ，搜索关键字 scrollpercent ,把 false 改为 true

如果想把 top 按钮放在侧边栏，搜索关键字`sidebar` , 把 false 改为 true

# 4. 设置菜单
编辑主题配置文件(`themes/next_config.yml`)，对应的字段是`menu`

```yml
menu:
  home: / || fa fa-home
  #about: /about/ || fa fa-user
  #tags: /tags/ || fa fa-tags
  categories: /categories/ || fa fa-th
  archives: /archives/ || fa fa-archive
  #schedule: /schedule/ || fa fa-calendar
  #sitemap: /sitemap.xml || fa fa-sitemap
  #commonweal: /404/ || fa fa-heartbeat
```

然后生成对应页面

```shell
hexo new page archives
hexo new page categories
```

然后修改新生成页面的类型`blog/souce/categories/index.md`, **否则进入categories页面是空的**

```toml
---
title: categories
date: 2023-04-18 23:05:34
type: "categories"
---
```

# 5. 代码块主题修改

编辑主题配置文件(`themes/next_config.yml`), 可以用搜索功能快速定位, 

```toml
codeblock:
  # Code Highlight theme
  # All available themes: https://theme-next.js.org/highlight/
  theme: github 
    #light: default
    dark: stackoverflow-dark
  prism:
    light: prism
    dark: prism-dark
  # Add copy button on codeblock
  copy_button:
    enable: true
    # Available values: default | flat | mac
    style: default
```

# 6. 配置目录
在主题配置文件(`themes/next_config.yml`)搜索`toc`
```toml
# Table of Contents in the Sidebar
# Front-matter variable (nonsupport wrap expand_all).
toc:
  enable: true
  number: false
  wrap: false
  expand_all: false
  max_depth: 6
```

# 7. 配置footer 猫猫脚印

编辑主题配置文件(`themes/next_config.yml`)

```toml
# ---------------------------------------------------------------
# Footer Settings
# See: https://theme-next.js.org/docs/theme-settings/footer
# ---------------------------------------------------------------
footer:
  icon:
    # Icon name in Font Awesome. See: https://fontawesome.com/icons
    name: fa fa-paw
    # If you want to animate the icon, set it to true.
    animated: false
    # Change the color of icon, using Hex Code.
    color: "#1E3050"
```

# 8. 配置建站时间

这个时间将在站点的底部显示，例如 `© 2013 - 2015`。 在(`themes/next_config.yml`)，搜索 `since`

```toml
footer:
  # Specify the year when the site was setup. If not defined, current year will be used.
  since: 2023
```

# 9. 设置自动抽取摘要

```shell
# 在博客根目录下执行
$ npm install hexo-excerpt --save
```

打开站点配置文件(根目录下的配置文件)，加入：

```yaml
excerpt:
  depth: 3  #按层来算，也就是按代码块来算
  excerpt_excludes: []
  more_excludes: []
  hideWholePostExcerpts: true
```

然后打开主题配置文件(`themes/next/`下的配置文件)，找到对应选项, 设置为 `true`：

```yaml
excerpt_description: true
...
read_more_btn: true
```

# 10. 开启LocalSearch搜索功能

## 安装相关插件

安装搜索插件： `hexo-generator-searchdb`

在博客根目录下执行以下命令：

```
$ npm install hexo-generator-searchdb --save
```

## 配置博客

编辑博客配置文件：`_config.yml`, **添加**下面这些内容

```
search:
  path: search.xml
  field: post
  format: html
  limit: 10000
```

## 配置主题

Next 主题自带搜索设置，编辑主题配置文件：`_config.yml`

找到文件中 Local search 的相关配置，设为 `true`

```
# Local search
local_search:
  enable: true
```

hexo 重新部署, 记得执行clean

参考:

- [NexT主题美化 | losophy](https://losophy.github.io/post/71afd747.html)
- [主题配置 - NexT 使用文档](https://theme-next.iissnan.com/theme-settings.html)
