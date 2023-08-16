---
title: "Git Branch"
date: 2023-04-22 00:47:50
categories:
  - Git
tags:
  - Git
---

## 1. Common Commands

List branches:

- `git branch`,  local, equals to `ls ./.git/refs/heads/`
- `git branch -r`, remote
- `git branch -a`, all
- you can add `-v` option, `git branch -v -a`

Check which branch you are on:

- `git status`

Create branch:

- `git branch <name>`

Switch branch:

- `git switch <name>`, only can switch to the branches on your local repository
- ``git checkout <name>`

Delete branch:

- `git branch -d <name>`

Merge benach `issue003` into current branch：

- `git merge <issue003>`

## 2. 切换分支需要注意的事

想要push到远程的哪个分支, 就必须在本地对应的分支修改文件, 否则会导致把修改push到错误的分支. 错误例子, 比如我有两个分支`main`和`backup`, 我想要把`content`push到`backup`分支上以用于备份, 可是我却每次在本地的main分支编辑博客(忘了转到`backup`分支)这就导致我往远程分支`origin/backup`push的时候说everything is up-to-date. 然后到github看是否备份, 发现并没有备份, 就出现了这种摸不清头绪的问题. 

然后创建的分支也不会立即生效, 你必须在该分支下有过commit记录, 才会成为真正的branch, 比如你创建(`git switch -c backup`)了分支`backup`但你没做任何提交, 然后转到了其他分支比如`master`, 然后当你从master分支重新转到`backup`分支的时候(`git switch backup`)会显示`fatal: invalid reference: backup`

验证, 

```shell
$ git init
$ git switch -c backup
Switched to a new branch 'backup'
$ git switch -c master
Switched to a new branch 'master'
# 下面这个指令输出为空, 即不存在任何branch
$ git branch -a
# 接下来在master创建文件然后commit修改
$ touch he    
$ git add .
$ git commit -m "add he"
$ git branch -a
* master
# 现在转到刚开始我们创建的backup分支, 可以看出并不存在, 因为我们没有做任何commit
$ git switch backup
fatal: invalid reference: backup
# 再次新建backup并做出commit
$ git switch -c backup
Switched to a new branch 'backup'
$ ls
he
$ vi he
$ cat he 
hello from backup
# 再创建个新文件
$ touch hello.txt
$ git add .
$  git commit -m "add hello.txt & updated he"
# 现在两个分支都存在了
$ git branch -a
* backup
  master
# 接下来确认在backup分支做的修改是否能在master分支查看到
$ git switch master                            
Switched to branch 'master'
$ ls
he
# 查看文件he 输出为空
$ cat he
```

可以发现分支`master`看不到我们在分支`backup`做出的改变(新建文件`hello.txt`和修改文件`he`), 这里要注意**修改文件之后如果你要切换分支, 你必须要进行commit**, 如果没有commit, 那这个文件就没有被tracked, 那即使你在`backup`新建文件或者修改(但不commit), 跳到其他分支后仍可以看到你在`backup`的修改, 所以**在切换分支前一定要确保你已经做了commit**. 

然后你可能有疑问, 那我们最开始在`master`分支创建了`he`, 然后也commit了, 为啥转到`backup`分支后, 仍然可以看到文件`he`呢? 其实这是因为`backup`分支还没被创建`he`分支就已经存在了, 如果我们现在在`master`分支创建个文件`test.txt`, 然后进行commit, 再新建个分支`dev`, 这时候`dev`可以看到`master`分支所有的文件, 但已存在的`backup`分支将看不到在`master`分支创建的`test.txt`. 

验证, 

```shell
$ git switch master   
Switched to branch 'master'
$ touch test.txt
$ ls
he       main.c   test.txt
$ git add .
$ git commit -m "add test.txt"
# 跳到backup分支看看能不能查看到新建文件test.txt
$ git switch backup
Switched to branch 'backup'
# 根据输出结果我们知道, backup看不到text.txt
$ ls
he        hello.txt
# 跳回master分支, 并新建dev分支
$ git switch master           
Switched to branch 'master'
$ git switch -c dev
Switched to a new branch 'dev'
# 可以看到新的分支可以看到master的所有文件
$ ls
he       main.c   test.txt
```

然后我们再来验证在`dev`分支修改文件之后, 如果未提交, 然后切换到其他分支仍可以看到修改的东西, 

```shell
$ cat main.c
#include<stdio.h>
int main() {
  return 0;
}

$ vi main.c 
$ cat main.c
#include<stdio.h>
int main() {
  printf("hello world");
  return 0;
}

$ git switch master 
$ cat main.c 
#include<stdio.h>
int main() {
  printf("hello world");
  return 0;
}
```

这时候如果我们在`master`提交, 那dev就看不到它之前添加的那一行hello world代码了,

```shell
$ git add .
$ git commit -m "add test.txt"
$ git switch dev   
$ cat main.c 
#include<stdio.h>
int main() {
  return 0;
}
```

有时候切换分支的时候, 会出现一下错误

```shell
$ git switch main 
error: Your local changes to the following files would be overwritten by checkout:
	content/posts/Merge&Rebase.md
Please commit your changes or stash them before you switch branches.
Aborting
#-------------------------#
$ git switch master
error: The following untracked working tree files would be overwritten by checkout:
	.DS_Store
Please move or remove them before you switch branches.
Aborting
```

所以结论是, **切换分支前, 一定要记得commit, 别在A分支修改你想提交到B分支的文件**.  

## 3. master vs. origin/master vs. remotes/origin/master

Take a clone of a remote repository and run `git branch -a` (to show all the branches git knows about). It will probably look something like this:

```shell
* master
  remotes/origin/HEAD -> origin/master
  remotes/origin/master
# 下面是我自己打印的, 与上面意思相同
[root@vultr GitTest]# git clone git@github.com:shwezhu/MyProject.git
[root@vultr GitTest]# cd MyProject/
[root@vultr MyProject]# git branch -a
* main
  remotes/origin/HEAD -> origin/main
  remotes/origin/main
```

Here, `master` is a branch in the local repository. `remotes/origin/master` is a branch named `master` on the remote named `origin`. You can refer to this as either `origin/master`, as in:

```
git diff origin/master..master
```

You can also refer to it as `remotes/origin/master`:

```
git diff remotes/origin/master..master
```

These are just two different ways of referring to the same thing (incidentally, both of these commands mean "show me the changes between the remote `master` branch and my `master` branch).

`remotes/origin/HEAD` is the `default branch` for the remote named `origin`. This lets you simply say `origin` instead of `origin/master`.

https://stackoverflow.com/a/10588561/16317008

## 4. 手动解决conflicts

```shell
$ git push origin dev 
To github.com:shwezhu/MyProject.git
 ! [rejected]        dev -> dev (fetch first)
error: failed to push some refs to 'github.com:shwezhu/MyProject.git'
hint: Updates were rejected because the remote contains work that you do
hint: not have locally. This is usually caused by another repository pushing
hint: to the same ref. You may want to first integrate the remote changes
hint: (e.g., 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

Git 提示我们先用`git pull`把最新的提交从`origin/dev`抓取(fetch)并在本地合并(merge)，再推送, 但是直接`git pull`并不好(`pull` = `fetch` + `merge`), 但你并不知道对方做了什么改动, 所以我们先用`git fetch`把远程的改动下载下来, 看看是啥, 再决定是否合并(`git merge `或 `git rebase`), 

```shell
$ git fetch origin origin/dev
$ git log --graph --oneline origin/dev dev
* a8b159b (HEAD -> dev) updated hello.txt by Mac:Shawn
| * 5828ddd (origin/dev) updated hello.txt by Server:John
|/  
* 87d20b9 (origin/main, main) add hello.txt by Mac:Shawn

$ git rebase origin/dev dev               
Auto-merging hello.txt
CONFLICT (content): Merge conflict in hello.txt
error: could not apply a8b159b... updated hello.txt by Mac:Shawn
hint: Resolve all conflicts manually, mark them as resolved with
hint: "git add/rm <conflicted_files>", then run "git rebase --continue".
hint: You can instead skip this commit: run "git rebase --skip".
hint: To abort and get back to the state before "git rebase", run "git rebase --abort"
```

提示需要手动解决所有的conflicts, 注意永远不要在public branch上使用`git rebase`, 之后我们会单讲`git rebase`和`git merge`. Git用`<<<<<<<`，`=======`，`>>>>>>>`标记出不同分支的内容，

```shell
$ cat hello.txt 
<<<<<<< HEAD
hello, this is John
=======
hello, this is Shawn
>>>>>>> a8b159b (updated hello.txt by Mac:Shawn)
```

因为是John先提交的, 所以我们把它的放前面, 改成如下(你想咋改咋改, 如果你觉得John写的不对, 你也可以删除他的内容只保留你的): 

```shell
$ vi hello.txt
$ cat hello.txt 
hello, this is John
hello, this is Shawn
```

然后在commit一下就行了, 这就是手动解决conflicts的过程, 即自己修改然后再做个commit, 

```shell
$ git add .
$ git commit -m "fixed conflicts"
[detached HEAD b3e495d] fixed conflicts
 1 file changed, 1 insertion(+)
 
$ git push origin dev
To github.com:shwezhu/MyProject.git
 ! [rejected]        dev -> dev (non-fast-forward)
error: failed to push some refs to 'github.com:shwezhu/MyProject.git'
hint: Updates were rejected because a pushed branch tip is behind its remote
hint: counterpart. Check out this branch and integrate the remote changes
hint: (e.g. 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.

$ git push -f origin dev
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Writing objects: 100% (3/3), 280 bytes | 280.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
To github.com:shwezhu/MyProject.git
 + 5828ddd...a8b159b dev -> dev (forced update)
```

为什么加了个`-f`(force)就可以了呢? [看到个解释](https://stackoverflow.com/a/62603479/16317008)很不错: 

`"The tip of your current branch is behind its remote counterpart"` means that there have been changes on the remote branch that you don’t have locally. And Git tells you to import new changes from `REMOTE` and merge it with your code and then `push` it to remote. 但是我们已经改过了呀, 所以我们需要override远程仓库的那个分支, 

You can use this command to force changes to the server with the local repository. remote repo code will be replaced with your local repo code. 

```shell
$ git push -f origin dev
```

With the `-f` tag you will override the *remote branch code* with your local repo code. 

> The `-f` is actually required because of the **rebase**. Whenever you do a rebase you would need to do a force push because the remote branch cannot be **fast-forwarded** to your commit. You'd **always** want to make sure that you do a pull before pushing, but if you don't like to force push to master or dev for that matter, you can create a new branch to push to and then merge or make a PR. https://stackoverflow.com/a/39400690/16317008

初学者不建议使用`rebase`,  更不能在public分支上使用`rebase`, 还是使用`merge`为好,  因为rebase操作是把你的分支的时间点直接搬到最新的分支, 因为我们fetch回的远程仓库的dev有新的提交, 所以我们直接把自己本地的“搬”到了远程的那个位置(如果无法理解rebase请看[这个解释](https://www.atlassian.com/git/tutorials/merging-vs-rebasing))所以就没有了本地的修改