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

Then go to Actions options, you can see your page is building in progess, when it finished, visit: https://your-username.github.io

> You probably need wait about 10 mintes even your the processof building bolgs has been finished, try to clear cache of your browser and restart your browser if you constantly get 404 page for yor website. 

### 2.3. Custom Domain (optional)

visit: https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/about-custom-domains-and-github-pages

Learn more: https://olowolo.com/post/hugo-quick-start/

## 3. Issues - 404 page

Hugo will make the url into lowercase automatically, therefore, make sure all you blog files and folders under `/content/post/` are lowercase. Otherwise, you will get 404 for that blog. 

And if you didn't make it lowercase before generate html pages with `hugo` command, then you need delete all the generated html files under `/public/post/` then run `hugo` command again, this should work. 