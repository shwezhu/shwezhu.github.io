---
title: "Git基础文件状态之版本穿梭"
date: 2023-05-05 09:31:30
categories:
  - Git
tags:
  - Git
---

学习Git的时候发现一些基础的概念很是模糊, 于是读了一下[文档](https://git-scm.com/book/en/v2/Git-Basics-Recording-Changes-to-the-Repository), 在这记录一下, 

Remember that each file in your **working directory** can be in one of **two states**: *tracked* or *untracked*. Tracked files are files that were in the last **snapshot**, as well as any newly **staged files**; they can be unmodified, modified, or staged. In short, tracked files are files that Git knows about. As you edit files, Git sees them as modified, because you’ve changed them since your last commit. As you work, you selectively stage these modified files and then commit all those staged changes, and the cycle repeats.

working directory就是我们项目下的所有文件, 我们使用Git就是为了记录它们, 然后staged files也是一个常见的名词, 比如我们修改了working directory下的`a.txt`然后使用`git add a.txt`stage文件`a.txt`, 但并没commit, 此时`a.txt`就是staged files(处于Git所谓的Staging Area), 然后我们commit修改, 这时候`a.txt`又变回了unmodified file, 然后再重复以上, 如下图, 文件的状态就是个圈圈:

![](a.png)

综上, `git add`有两个功能:

- 把一个修改的文件stage到Staging Area
- 把一个新的文件从`untracked`变成到`tracked`状态

### Modified -> Unmodified

早上接到老板的命令, 把昨天实现的功能再修改一下, 然后还没吃早饭你的开始各种操作, 俩小时整好了, 正准备add, commit,  然后突然老板打电话说客户又不想要了(WTF?), 然后你要一行一行把代码修改回之前的的内容吗?  不要怕, 我们的git可以帮助你, 

理论不如实践, 我们修改一下`a.txt`(注意`a.txt`已经是tracked file), 然后观察它的状态:

```shell
$ echo "hello" > a.txt 
$ git status 
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   a.txt

no changes added to commit (use "git add" and/or "git commit -a")
```

你看Git提示告诉了我们很多东西, 都不用查谷歌了,  我们已经知道`git add`是什么了,  `git restore <file>...`就是撤销刚刚的修改`a.txt`, 

```shell
$ git restore a.txt 
$ git status
On branch main
nothing to commit, working tree clean
```

这时我们就已经把`a.txt`恢复到之前的内容了, 你看提示说working tree时clean的. 注意我们可以使用`git restore`撤销刚对`a.txt`的修改, 是因为它已经是tracked file, 所谓的撤销修改即把`a.txt`的内容从刚修改的又变回没修改之前的内容(即上一次commit的时候的内容). 这也就所谓的版本穿梭. 

如果我们修改一个untracked file, 那git都没保存它之前的内容, 也就不存在`git restore`这一说, 如下:

```shell
$ touch e.txt 
$ echo "hello" > e.txt 
$ git status       
On branch main
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	e.txt

nothing added to commit but untracked files present (use "git add" to track)
```

你看提示没说让我们`git restore`它吧, 只是提示我们去使用`git add`去track这个文件.

### Staged -> Modified

如果你老板在你刚stage文件到staging area的时候给你打电话(还没commit), 那你应该怎么把文件从staged变回没修改之前呢? 

分两步: 

- Staged->Modified
- Modified->Unmodified 上面我们已经讨论过

```shell
$ echo "hi" > a.txt 
$ git add a.txt 
$ git status
On branch main
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	modified:   a.txt

# 根据提示从staged->modified
$ git restore --staged a.txt 
$ git status
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   a.txt

no changes added to commit (use "git add" and/or "git commit -a")
# 根据提示从modified->unmodified
$ git restore a.txt 
$ git status
On branch main
nothing to commit, working tree clean
```

### Tracked -> Untracked

To remove a file from Git, you have to remove it from your tracked files (more accurately, remove it from your staging area) and then commit. The `git rm` command does that, and also removes the file from your working directory so you don’t see it as an untracked file the next time around.

If you simply remove the file from your working directory, it shows up under the “Changes not staged for commit” (that is, *unstaged*) area of your `git status` output:

```shell
# 删除a.txt不用害怕, 因为它是tracked file, 我们可以使用git restore去回复它
$ rm a.txt 
$ git status 
On branch main
Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	deleted:    a.txt

no changes added to commit (use "git add" and/or "git commit -a")
```

**Then**, if you run `git rm`, it stages the file’s removal:

```shell
$ git rm a.txt
rm 'a.txt'
$ git status
On branch main
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	deleted:    a.txt
```

The next time you commit, the file will be gone and no longer tracked. If you modified the file or had already added it to the staging area, you must force the removal with the `-f` option. This is a safety feature to prevent accidental removal of data that hasn’t yet been recorded in a snapshot and that can’t be recovered from Git.

Another useful thing you may want to do is to keep the file in your working tree but remove it from your staging area. In other words, you may want to keep the file on your hard drive but not have Git track it anymore. This is particularly useful if you forgot to add something to your `.gitignore` file and accidentally staged it, like a large log file or a bunch of `.a` compiled files. To do this, use the `--cached` option:

```shell
$ git rm --cached a.txt
```

这里我实验了一下, 即新建一个文件然后stage它, 然后使用下面这两个命令去upstage实现的效果是一样的, 

```shell
$ git rm --cached h.txt
$ git restore --staged h.txt
```

然后我在[StackOverflow](https://stackoverflow.com/a/74187033/16317008)查了一下区别, 

The two are entirely different commands:

- `git restore` is about *copying* some file(s) from somewhere to somewhere.
- `git rm` is about *removing* some file(s) from somewhere.

Because `git restore` is about *copying* a file or files, it needs to know *where to get the files*. There are three possible sources:

- the current, or `HEAD`, commit (which must exist); or
- any arbitrary commit that you specify (which must exist); or
- Git's *index* aka *staging area*.

Because `git rm` is about *removing* a file or files, it only needs to know the name(s) of the file(s) to remove. Adding `--cached` tells `git rm` to remove these files *only* from **Git's index aka *staging area*.** 我们看一下提示, 也会得到信息, 只是那时候还不知道index是啥, 现在知道啦, index就是staging area, 

```shell
$ git rm --
--cached              -- only remove files from the index
--dry-run             -- do not actually remove the files, just show if they exist
--force               -- override the up-to-date check
```

### 总结

综上, 工作目录下的文件有很多状态, Untracked, Tracked, Unmodified, Modified, Staged, 然后我们使用下面的命令进行版本穿梭, 

- `git add`modified->staged

- `git commit` staged->unmodifed
- `git rm`注意这个命令有参数用来告诉从哪删除如` git rm --cached h.txt`, 从tracked->untracked(此时会真正删除文件, 但你也可以恢复), 从staged->modified, 
- `git restore`,  从staged->modified, 从modified->unmodified都可以使用这个命令

当然还有其它命令没提到, 如`git reset`等...也可用于版本穿梭, 这个文章只是想阐述一些基础的概念, 如Git的index就是staging area, working directory等概念, 以便在查找资料的时候可以看懂别人在说什么. 