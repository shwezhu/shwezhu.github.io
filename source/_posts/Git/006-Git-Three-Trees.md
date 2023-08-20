---
title: "Git撤销提交之The Three Trees"
date: 2023-05-04 19:40:30
categories:
  - Git
tags:
  - Git
---

然后就看到了下面这几个命令, 一愣一愣的, 想弄明白这个HEAD到底是个啥, 

```shell
# 回退到上个版本
git reset --hard HEAD^
# 退到/进到 指定commit_id
git reset --hard commit_id
# 将本地的修改提交到远程
git push origin HEAD --force
```

看下[文档](https://git-scm.com/book/en/v2/Git-Tools-Reset-Demystified)怎么说, 

> HEAD is the pointer to the current branch reference, which is in turn a pointer to the last commit made on that branch. That means HEAD will be the parent of the next commit that is created. It’s generally simplest to think of HEAD as the snapshot of **your last commit on that branch**. 即你可以把HEAD看成你所在分支的最后一个commit的snapshot. 

所以对于上面的`git reset --hard HEAD^`, HEAD代表最新的一次提交, 也就是我提交错的那次, 然后`HEAD^`代表的是最新的一次提交之前的那次提交, 所以这个命令就知道是啥意思了, 也就是所谓的“撤销”commit, 其实说版本回退更合适. 至于`git reset --hard commit_id`很好理解, 就是回退到指定版本呗, 至于commit id可以通过`git log`查看. 

然后上面说HEAD是最后一个commit的snapshot, 我们来看看到底是个啥, 首先我的本地仓库只有个`a.txt`文件, 然后做了两次commit, 

```shell
git cat-file -p HEAD                     
tree 93c3ebcab393ef429492dd7685cb952e78f91bf2
parent 13999ee3b83ed0fb7f19557867d25a4669b09079
author David Zhu <shaowenzhu@dal.ca> 1683258255 -0300
committer David Zhu <shaowenzhu@dal.ca> 1683258255 -0300

git ls-tree -r HEAD                      
100644 blob 9a71f81a4b4754b686fd37cbb3c72d0250d344aa	a.txt
```

看到上面的那个HEAD的parent了吗, 其实就是它前一次的commit id, 使用`git log`看一下

```shell
commit eb3cf74db1b2a5ffa85839caab3f3a3e02a65ba0 (HEAD -> main)
Author: David Zhu <shaowenzhu@dal.ca>
Date:   Fri May 5 00:44:15 2023 -0300

commit 13999ee3b83ed0fb7f19557867d25a4669b09079
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Thu May 4 17:14:59 2023 -0300
```

### The Three Trees

Git[文档](https://git-scm.com/book/en/v2/Git-Tools-Reset-Demystified)里的这个概念很好, 很多时候都会涉及到这三个常用的Tree, 

Git as a system manages and manipulates three trees in its normal operation:

| Tree              | Role                              |
| :---------------- | :-------------------------------- |
| HEAD              | Last commit snapshot, next parent |
| Index             | Proposed next commit snapshot     |
| Working Directory | Sandbox                           |

上面的Index的role是`Proposed next commit snapshot`, 然后HEAD是`Last commit snapshot, next parent`, 好像是一个在未来, 一个在从前, 说HEAD在从前是正确的, 上面我们已经讨论, HEAD就是上一次提交的snapshot, 但是Index其实说它是现在更贴切, 因为Index就是Staging Area, 即我们staged文件都在这个地方, 准备使用commit提交, 即所谓的Proposed next commit snapshot. 

The Git index is a critical data structure in Git. It serves as the “staging area” between the files you have on your filesystem and your commit history. When you run `git add`, the files from your working directory are hashed and stored as objects in the index, leading them to be “staged changes”. When you run `git commit`, the staged changes as stored in the index are used to create that new commit.

HEAD在上面已经解释, 至于 working directory 已经在: [Git基础文件状态之版本穿梭 | 橘猫小八的鱼](https://davidzhu.xyz/2023/05/05/Git/001-Git-Basics/) 提到,  在这不再赘述, 

### The Workflow

Git’s typical workflow is to record snapshots of your project in successively better states, by manipulating these three trees.

![](a.png)

还记得上一篇文章我们说的git restore, git rm, git reset的区别吗, 再看看上面这个图, 是不是觉得前后呼应了:

The two are entirely different commands:

- `git restore` is about *copying* some file(s) from somewhere to somewhere.
- `git rm` is about *removing* some file(s) from somewhere.

Because `git restore` is about *copying* a file or files, it needs to know *where to get the files*. There are three possible sources:

- the current, or `HEAD`, commit (which must exist); or
- any arbitrary commit that you specify (which must exist); or
- Git's *index* aka *staging area*.

如果想理解gir reset的`--hard`, `--soft`的区别, 请看这个文章, 并读完, [Git - Reset Demystified](https://git-scm.com/book/en/v2/Git-Tools-Reset-Demystified#_git_reset)
