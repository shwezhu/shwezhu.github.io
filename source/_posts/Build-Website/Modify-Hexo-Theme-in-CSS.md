---
title: 微修Hexo主题CSS文件思路记录
date: 2023-04-27 18:30:22
categories:
 - Build Website
tags:
 - CSS
---

博客的一级标题和二级标题颜色不太一样, 看着很不爽, 于是想找到对应代码改一下, 

打开博客网页进入开发者模式, 查看二级标题对应的css文件以及所属标签名称, 如下图:

![](a.png)

在`blog/themes/cactus/source/css/style.styl`中没找到对应代码, 想到上面有`import`, 如下: 

```css
@import "_variables"
@import "_colors/" + $colors
@import "_util"
@import "_mixins"
@import "_extend"
@import "_fonts"
...
```

于是在`blog/themes/cactus/source/css/_extend.styl`中找到了对应的内容, 如下:

```css
$base-style
  h1, .h1
    display: block
		...
  h2, .h2
    position: relative
    display: block
    margin-top: 2rem
    margin-bottom: .5rem
    color: $color-accent-2
    ...
```

把`h2`颜色改成和`h1一样就好了, 看着上下间隔貌似有点大, 于是又改了一下1-3级标题, 这里它只设置了1-2级标题,  改第三级标题的时候发现下面单独定义了3级标题的上下间隔, 防止冲突删除了在下面单独定义的地方删除了3级标题, 如下:

```css
   h3, .h3
    position: relative
    display: block
    margin-top: 1rem
    margin-bottom: .3rem
    color: $color-accent-1
    text-transform: none
    letter-spacing: normal
    font-weight: bold
    font-size: 1.0rem 

  h4
  h5
  h6
    margin-top: .9rem
    margin-bottom: .5rem
```

其中`em`和`rem`的区别是, `rem`是相对的relative, 所以上面的`.9`, `.5`,就是90%, 和一半的的意思, 相对谁可以谷歌一下懒得查了, 然后它的值也可以大于1, 即n倍. 

---

注意修改CSS文件部署到服务器后, 有时侯因为本地缓存, 并不会立即生效, 不用重复部署, 直接选择对应网站点击清理cache即可. 
