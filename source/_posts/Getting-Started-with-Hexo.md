---
title: Getting Started with Hexo
date: 2023-04-22 16:51:47
tags:
 - Hexo
---

1. 安装配置hexo
2. 部署hexo到GitHub

<!-- more -->

# 1. 远程配置

创建仓库, 名为`<your username>.github.io`, 如下:

![](a.png)

# 2. 本地配置

本地安装hexo参考前面文章, 

```shell
hexo init blog
cd blog/
# 安装主题
git clone https://github.com/next-theme/hexo-theme-next themes/next
vi _config.yml
```

修改配置文件如下:

```shell
# Extensions
## Themes: https://hexo.io/themes/
theme: next

# Deployment
deploy:
  type: git
  # 注意不要填https://github.com/shwezhu/shwezhu.github.io.git
  # 否则你在hexo deploy的时候需要输入账号密码 即使你在github加入了ssh public key
  repo: git@github.com:shwezhu/shwezhu.github.io.git
  branch: master
```

生成静态文件然后部署到github, 

```shell
# 不安装hexo-deployer-git这个会提示错误
# ERROR Deployer not found: git
npm install hexo-deployer-git --save
hexo clean
hexo g
hexo d
```

然后访问`username.github.io`即可, 别忘在仓库设置页面的pages页设置默认分支, 注意部署后可能要等大概三五分钟才能生效, 刚部署就访问可能会遇到404错误, 可以在GitHub仓库的Actions页面查看:

![](b.png)
