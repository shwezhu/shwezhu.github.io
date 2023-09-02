---
title: essence of "origin" - git fetch & git remote
date: 2023-04-21 21:46:44
categories:
  - git
tags:
  - git
---

## git fetch & git remote

The `git fetch` command downloads commits, files, and refs from a remote repository into your local repo. Fetching is what you do when you want to see what everybody else has been working on. **Git isolates fetched content from existing local content; it has absolutely no effect on your local development work**. 

## git fetch commands and options

Fetch all of the branches from the repository. This also downloads all of the required commits and files from the other repository.

```shell
$ git fetch <remote>
```

Same as the above command, but only fetch the specified branch.

```shell
$ git fetch <remote> <branch>
# git fetch origin origin/main 
```

这里的`<remote>`就是远程仓库的url, 但是我们一般会为远程仓库的url设置个简单的名字, 以便我们使用, 其实`origin`就是我们一般默认使用的名字来代指远程仓库的url. 

想要理解这个`<remote>`到底是什么, 还是得知道另一个常用命令`git remote`, 熟悉吧, 这就是我们每次链接远程仓库必用的指令, 我们的流程在GitHub创建个仓库, 然后在本地创建个同名文件夹, 进入文件夹先使用`git remote add origin git@github.com:shwezhu/MyProject.git`, 最后使用 `git init`等指令, 一套操作行云流水, 直接push到远程仓库. 

有没有想过上面的指令`git remote add origin git@github.com:shwezhu/MyProject.git`, 其中的`git remote`是什么? 以及`add`后的`origin`又是什么? 

`git remote`就是 git 指令, `origin` 就是后面的url的别名, 你也可以改成其他的, 什么`repo`都可以的, 只不过那时候你再向远程push东西就得是`git push repo master`之类的指令了, 而不是`git push origin master`. 

我们先来看一下`git remote`, 

The `git remote` command is also a convenience or 'helper' method for modifying a repo's `./.git/config` file. The commands presented below let you manage connections with other repositories. The following commands will modify the repo's `/.git/config` file. The result of the following commands can also be achieved by directly editing the `./.git/config` file with a text editor. 

```shell
git remote add <name> <url>
```

Create a new connection to a remote repository. After adding a remote, you’ll be able to use `＜name＞` as a convenient shortcut for `＜url＞` in other Git commands. 

根据上面所说即`<name>`就是`<url>`的别名, 而上面指令`git fetch <remote>`中的`<remote>`就是`git remote add <name> <url>`中的`<name>`, 所以下面两个指令是等效的:

```shell
git fetch origin
# 等价于
git fetch git@github.com:shwezhu/MyProject.git
```

注意, 上面这两个指令等价的前提是你执行了以下命令:

```shell
git remote add origin git@github.com:shwezhu/MyProject.git
```

## conclusion

- origin 是远程仓库 url 的别名, 可以改成其他的, 如 repo, 但是之后push代码时, 需要使用命令 `git push repo master`
  -  添加远程仓库时指定 url 别名 origin:`git remote add origin git@github.com:shwezhu/MyProject.git`
  -  `git remote add <name> <url>` 
  -  可以用 ` git remote` 查看当前 url 别名
  -  `git remote rename repo origin` 修改
- ` git fetch <remote>` 中的 `<remote>`  就是远程仓库的 url, 可以用 url 别名代替 如 origin, repo
- 配置信息在 ` .git/config ` 

参考:

- [Git Remote | Atlassian Git Tutorial](https://www.atlassian.com/git/tutorials/syncing)
- [Git Fetch | Atlassian Git Tutorial](https://www.atlassian.com/git/tutorials/syncing/git-fetch)

