---
title: 解决 npm 无法安装 packages 到本地文件夹问题
date: 2023-06-27 11:24:35
categories:
 - Bugs
tags:
 - Bugs
 - Nodejs
---

使用 `npm install xxx`, 然后总是安装到 `~/node_modules/`, 查了好多, 有的说用 `npm config list   `查看 global 的值, 改为 false 什么, 都没有用, 

卸载 node 和 npm 重装依旧不能解决, 

最后删除了  `~/node_modules/` 文件夹和 `~/` 下的所有 npm 相关文件夹, 然后重新运行 `npm install xxx` 后本地文件夹自动创建 `node_modules`, 安装成功. 

在知乎看到的回答:

> npm的原理大概就是从当前目录往上找，找到哪个目录有node_modules就认为这才是真正的项目目录，所以东西全给装那里面去, 所以不仅仅是User根目录的问题，你得保证从你当前的目录开始一直到根目录都没有node_modules，npm才会“正常”地把东西放到当前目录下的node_modules里 [原文](https://www.zhihu.com/question/33302274/answer/56276831)

