---
title: Three Trees & HEAD in Git
date: 2023-05-04 19:40:30
categories:
  - git
tags:
  - git
---

## HEAD

下面这几个命令, 看的一愣一愣的, 想弄明白这个HEAD到底是个啥, 

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

## Three Trees

Git[文档](https://git-scm.com/book/en/v2/Git-Tools-Reset-Demystified)里的这个概念很好, 很多时候都会涉及到这三个常用的Tree, 

Git as a system manages and manipulates three trees in its normal operation:

| Tree              | Role                              |
| :---------------- | :-------------------------------- |
| HEAD              | Last commit snapshot, next parent |
| Index             | Proposed next commit snapshot     |
| Working Directory | Sandbox                           |

The Git index is a critical data structure in Git. It serves as the “staging area” between the files you have on your filesystem and your commit history. When you run `git add`, the files from your working directory are hashed and stored as objects in the index, leading them to be “staged changes”. When you run `git commit`, the staged changes as stored in the index are used to create that new commit.

## The Workflow

Git’s typical workflow is to record snapshots of your project in successively better states, by manipulating these three trees.

![](/006-git-three-trees/a.png)

还记得上一篇文章我们说的 git restore, git rm, git reset 的区别吗, 再看看上面这个图, 是不是觉得前后呼应了:

The two are entirely different commands:

- `git restore` is about *copying* some file(s) from somewhere to somewhere.
- `git rm` is about *removing* some file(s) from somewhere.

Because `git restore` is about *copying* a file or files, it needs to know *where to get the files*. There are three possible sources:

- the current, or `HEAD`, commit (which must exist); or
- any arbitrary commit that you specify (which must exist); or
- Git's *index* aka *staging area*.

关于 gir reset `--hard`, `--soft` 区别, 可参考 [Git - Reset Demystified](https://git-scm.com/book/en/v2/Git-Tools-Reset-Demystified#_git_reset)
