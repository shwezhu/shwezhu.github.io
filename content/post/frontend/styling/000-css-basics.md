---
title: HTML Elements
date: 2024-05-05 17:20:20
categories:
 - front-end
 - html
---

## 0. 小建议

CSS 内容, 并列的element放一块, 而不是分类放, 这样修改比较容易找位置看对比, 比如下面的内容, 最好是把 `course-details` 和 `course-title-description` 的 css 放一块, 这样我们想修改二者的css做对比的时候才比较好找他们对应的css, 而不是每次都得往下翻很久...

```html
<article className="course-card">
  <div className="course-title-description">
    ...
  </div>
  <div className="course-details">
    <div className="course-meta">
      ...
    </div>
    <div className="course-stats">
      ...
    </div>
  </div>
</article>
```

## 1. HTML Elements 

`<span>` is very much like a `div` element, but `span` is a block-level element whereas a `<span>` is an **inline-level element**. `<a>` creates hyperlinks to connect to other content.

**Block-level** elements create new lines and take full width:`<h1>` to `<h6>` for headings, `<p>` for paragraphs. 

### 2. 计算单位

### 2.1. `rem` vs `em`

rem 是 "root em" 的缩写, 它是一个相对单位, 基于根元素（即 html 元素）的字体大小来计算

```css
html {
    font-size: 10px;    /* 将根元素字体大小设为 10px */
}

.example2 {
    font-size: 1.6rem;  /* 现在等于 16px */
    margin: 2rem;       /* 现在等于 20px */
}
```

> rem 单位和 em 单位的主要区别在于，em 是相对于父元素的字体大小计算的，这可能会导致复杂的嵌套计算问题

### 2.2. `vw`, `vh`, `dvh` vs `100%`

 `vw/vh` 是相对于视口（viewport）的单位, `%` 是相对于父元素的单位.

**踩坑1:** `vw` 或者 `vh` 可能会导致滚动条:

```css
/* 问题：会导致水平滚动条 */
.full-width {
    width: 100vw;
    padding: 20px;
}

/* 解决方案：使用 calc */
.full-width-fixed {
    width: calc(100vw - 40px);
    padding: 20px;
}
```

**踩坑2:** 100% 是基于父元素, 所以使用的时候需要先设置父元素的宽度或高度

```css
/* 问题：当父元素没有明确高度时，100% 不生效 */
.parent {
    position: relative;
}
.child {
    height: 100%;  /* 无效 */
}

/* 解决方案：使用 vh 或设置父元素高度 */
.parent {
    height: 100vh;
}
.child {
    height: 100%;  /* 现在有效了 */
}
```

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/11/a517a416eaa2606c04cdd7a8a839b1f4.jpg)

> 过度使用 vw/vh 可能导致频繁的重排, 影响性能,

**踩坑3:** 移动端 

```css
/* 问题：在移动端，100vh 会包含地址栏高度 */
.mobile-full-height {
    height: 100vh;  /* 可能出现滚动 */
}

/* 解决方案：使用新的动态视口单位 */
.mobile-full-height-fixed {
    height: 100dvh;  /* 动态视口高度 */
}
```

> vh 单位在移动端浏览器中可能会有不一致的行为, 考虑使用新的动态视口单位（dvh、svh、lvh）来处理移动端的特殊情况

`dvh` 会随着浏览器界面的变化动态调整, 当用户滚动页面时, 如果地址栏收起或展开(Safari经常这样), 使用 dvh 的元素高度会相应变化, 这可能会导致：导航栏高度不稳定, 页面内容跳动, 用户体验不连贯

`svh` 使用视口的最小可能高度，也就是当移动浏览器的工具栏/地址栏完全展开时的高度, 使用 `svh` 的优势在于, 导航栏高度始终基于最小视口高度计算, 即使地址栏收起，导航栏的高度也不会改变

`lvh` 使用视口的最大可能高度, 即当浏览器的工具栏/地址栏完全隐藏时的高度, 全屏背景图片或视频, 沉浸式体验的页面可以尝试, 

## 3. Position Absolute

> Absolute positioned elements are removed from the normal flow, and **can overlap elements**.

写菜单栏的时候, 菜单栏展开后会将下面的内容挤下去, 像下面这样:

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/08/a199c94496cc4d1f2fbfdd7fd09478c4.jpg)

基本上菜单栏都很窄, 所以当菜单栏展开时, 我希望的是不影响下面的内容, 但是正常情况下两个元素要么是 inline 那种可以在同一行, 要么是 block 那种独占一行, 无法实现我想要的效果. 此时就可以使用 absolute 来实现, 如下:

![](https://pub-2a6758f3b2d64ef5bb71ba1601101d35.r2.dev/blogs/2024/08/997c2961834e857ceb3fbc392b90cb56.jpg)

此时也应该注意覆盖的问题, 若对话框宽度为 100vw, 可能会覆盖掉对话框, 因此要将 z-index 设置大一些. 

