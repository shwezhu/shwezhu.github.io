---
title: "Write Blog with Hugo & Deploy to Github Pages"
date: 2023-08-31 23:51:57
categories:
  - Build Website
tags:
  - Hugo
---

## 1. Basic Commands

```shell
# create a website
$ hugo new site blogs
# see your websites locally
$ hugo server
# generate static html file in public folder
$ hugo
```

## 2. Deploy to Github Pages

### 2.1. Local Repository

```shell
$ cd blogs/public/
$ git init
$ git remote add origin git@github.com:shwezhu/shwezhu.github.io.git
...
$ git branch -M master
$ git push origin master
```

### 2.2. Remote Repository

Go to Settings -> Pages -> Build and deployment

Source: depoly from a branch

Branch: choose `master`

## 3. Custom Domain

visit: https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/about-custom-domains-and-github-pages

Learn more: https://olowolo.com/post/hugo-quick-start/