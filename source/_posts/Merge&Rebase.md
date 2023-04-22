---
title: "Merge&Rebase"
date: 2023-04-21T09:44:39-03:00
tags:
  - Git
---

还没想好写啥

<!-- more -->

## 1. master vs. origin/master vs. remotes/origin/master

 





## 2. Fast Forward





push的时候必须在该分支, 比如你想往远程的backup分支push东西, 那你就要在backup进行创建文件然后add, commit, 然后进行push, 你不能在master进行add和commit, 然后在backup分支提交东西, 这是不对的. 比如我本来在main分支创建的文件, 然后我转到了backup, 这时候文件就没了(因为文件在main那), 



如果你在一个分支修改了东西, 那就要commit, 不然会有以下错误

```
git switch main 
error: Your local changes to the following files would be overwritten by checkout:
	content/posts/Merge&Rebase.md
Please commit your changes or stash them before you switch branches.
Aborting
```

