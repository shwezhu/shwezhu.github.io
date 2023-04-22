---
title: Deploy Blogs with Hexo
categories:
  - - hexo
  - - build website
date: 2023-04-17 19:25:31
---

文件结构介绍, 正确插入图片, 设置文章生成唯一url以及使用文章分类

<!-- more -->

# 1. Folder Intro
```shell
hexo init blog && cd blog/

tree -L 1
.
├── _config.landscape.yml
├── _config.yml
├── db.json
├── node_modules
├── package-lock.json
├── package.json
├── public
├── scaffolds
├── source
└── themes

# 只列出一部分文件结构
tree -L 2
.
├── _config.yml
├── public
│   ├── 2023
│   ├── archives
│   ├── css
│   ├── images
│   ├── index.html
│   └── js
├── scaffolds
│   ├── draft.md
│   ├── page.md
│   └── post.md
├── source
│   └── _posts
└── themes
    └── next
```

## 1.1. public

可以看到, `public`文件夹就是我们的网页内容, 也就是`hexo generate`生成的静态文件, 我们`hexo deploy`到网站上的东西就是这个文件下的东西, 如下图:

![''](a.png)

## 1.2.  _config.yml

全局配置文件, 我们的deploy, 选择主题都是在这配置的, 但是如果配置具体主题细节, 我们需要进到`themes`文件夹下, 再进入相关的主题文件中, 如next, 然后`themes/next/`下也有个`_config.yml`, 我们需要在这配置. 

## 1.3. scaffolds

`scaffolds`是“脚手架、骨架”的意思，当你新建一篇文章（`hexo new 'title'`）的时候，hexo是根据这个目录下的文件进行构建的。貌似是个模板一样的东西, 

## 1.4. source

`source/`目录很重要，新建的文章都是在保存在这个目录下的，有两个子目录：`_drafts`，`_posts`。需要新建的博文都放在`_posts`目录下。`_posts`目录下是一个个markdown文件。你应该可以看到一个`hello-world.md`的文件，文章就在这个文件中编辑。

`_posts/`目录下的md文件，会被编译成html文件，放到`public/`

# 2. 创建博客

最初scaffolds和source内容如下, 
```shell
├── scaffolds
│   ├── draft.md
│   ├── page.md
│   └── post.md
├── source
│   └── _posts
│       └── hello-world.md
```

基础命令如下:

```
hexo new <layout> title
```

其中parameter `layout`是上面我们介绍的`scaffolds/`下的模板名字, 如上面的输出最初`scaffolds/`下有`draft.md`, `page.md`, `post.md`, 那么`layout`的的值可以为`post`, `draft`, `page`, hexo会根据不同模板为我们在`source/_post/`下初始化不同内容的`md`文件, 以便于我们省事, 不用写一些必要信息(什么创建日期, 文章title等), 

e.g., 

```shell
hexo new post "New Post with Hexo"

cat source/_posts/New-Post-with-Hexo.md 
---
title: New Post with Hexo
date: 2023-04-17 19:10:24
tags:
---
```

# 3. 利用Hexo-abbrlink插件生成唯一文章链接

如果你使用了它, 那以后转移博客到其他网站将会很麻烦, 因为文章链接会变, 不使用Hexo-abbrlink的话就很简单, 只要不改文章标题就行, 

Hexo在生成博客文章链接时，默认是按照年、月、日、标题格式来生成的，可以在站点配置文件中指定new_post_name的值。默认是:year/:month/:day/:title这样的格式。如果你的标题是中文的话，你的URL链接就会包含中文。复制后的url路径就是把中文变成了一大堆字符串编码，如果你在其它地方用了你自己这篇文章的url链接，偶然你又修改了该文章的标题，那这个url链接岂不是失效了。

```shell
# 比如现在的博客名字为 Deploy Blogs with Hexo
# 则博客链接为
https://shwezhu.github.io/2023/04/17/Deploy-Blogs-with-Hexo/#more
```

为了给每一篇文章来上一个属于自己的链接，可以利用hexo-abbrlink插件，来解决这个问题。

首先安装下hexo-abbrlink

```shell
npm install hexo-abbrlink --save
```

站点配置文件(`_config.yml`)里改为

```shell
permalink: post/:abbrlink.html
abbrlink:
  alg: crc32  # 算法：crc16(default) and crc32
  rep: hex    # 进制：dec(default) and hex
```

生成完后,原文章md文件的Front-matter 内会增加abbrlink 字段,值为生成的ID 。这个字段确保了在我们修改了Front-matter 内的博客标题title或创建日期date字段之后而不会改变链接地址,换句话说,就是本篇文章有了自己的专属链接。

注意，这个配置完成之后，文章的链接有可能会变成了undefined，新的文章没问题，老的文章不行。执行hexo clean清掉以前生成的文章缓存，然后hexo g重新渲染就ok了。

# 4. 文章摘要

设置文章摘要，我们只需在想显示为摘要的内容之后添 `<!-- more -->` 即可。像下面这样：

```shell
---
title: hello hexo markdown
date: 2016-11-16 18:11:25
tags:
- hello
- hexo
- markdown
---

我是摘要....

<!-- more -->

紧接着摘要的正文内容...
```

这样，<!-- more --> 之前、文档配置参数之后中的内容便会被渲染为站点中的文章摘要。

# 5. 插入图片

写个客有时候会想添加个图片或者其他形式的资源等等。有以下两种方式进行解决：

- 使用绝对路径引用资源，在 Web 世界中就是资源的 URL
- 使用相对路径引用资源

对于使用相对路径引用资源的，我们可以使用 Hexo 提供的资源文件夹功能。

## 5.1. 修改配置文件
使用文本编辑器打开站点根目录下的 `_ config.yml` 文件，修改内容如下:

```shell
post_asset_folder: true
marked:
  prependRoot: true
  postAsset: true
```

修改之后会开启 Hexo 的文章资源文件管理功能。Hexo将会在我们每一次通过 `hexo new <title>` 命令创建新文章时自动创建一个同名文件夹，于是我们便可以将文章所引用的相关资源放到这个同名文件夹下，然后通过相对路径引用。

### 安装hexo-renderer-marked插件

```shell
npm install hexo-renderer-marked --save
```

> 注意: 安装的packages在`blog/node_modules/`下面, 备份的时候这个文件夹不用备份, 我们只用备份`package.json`文件就行

一些人推荐安装hexo-asset-image插件, 这里不推荐(如果你不打算使用文章链接永久化, 那可以使用它), 因为hexo-asset-image之后, 然后又使用了文章链接永久化插件, 之后生成的img的地址是错误的, 导致无法渲染, 查看blog根目录下的public里生成的对应文章的的html文件, 看看对应图片的url到底是什么, 为什么没有被渲染出来, 如下图: 其中与html同名的文件夹`4233be2c`内存的就是图片, 但是html文件中的img的url却是`src="post/4233be2c.htm/a.png"` 咱也不知道`4233be2c.htm`多出的`htm`是什么鬼, 

![](b.png)

### **e.g.,** 

```shell
$ hexo new post "how to code"
INFO  Validating config
INFO  Created: ~/Downloads/blog/source/_posts/how-to-code.md

$ ls source/_posts 
Deploy-Blogs-with-Hexo	Deploy-Blogs-with-Hexo.md            
how-to-code    how-to-code.md

# 向同名文件夹how-to-code放要插入的图片
ls source/_posts/how-to-code 
a.png
```

`md`文件的内容:

```c
---
title: article-1
date: 2023-04-17 19:25:31
tags:
---

Hi, I'm digest...

<!-- more -->

这里是正文,,,,

!['name of picture'](a.png)
```

测试

```shell
# hexo clean
hexo g
hexo s
# hexo d
```

# 6. 文章分类

```shell
---
title: Deploy Blogs with Hexo
date: 2023-04-17 19:25:31
tags: 
  - - hexo
  - - build website
---
```

# 7. 命令总结

每次发布的时候想预览可以使用`hexo server`指令, 因为你直接deploy到网站的话, 可能要等几分钟才能生效, 一般发布文章或预览, 命令如下“

```shell
hexo new post "pos name"
# hexo clean
hexo g
hexo s
# hexo d
```

参考:

- [Front-matter | Hexo](https://hexo.io/zh-cn/docs/front-matter.html)
- [hexo博客中如何插入图片 - 掘金](https://juejin.cn/post/6882619951857811469)

