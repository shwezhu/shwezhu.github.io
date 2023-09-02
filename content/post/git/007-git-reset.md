---
title: Git Reset 
date: 2023-05-31 10:20:23
categories:
  - Git
tags:
  - Git
---

前置: [Git撤销提交之The Three Trees | 橘猫小八的鱼](https://davidzhu.xyz/2023/05/04/Git/006-Git-Three-Trees/)

原文: [Git - Reset Demystified](https://git-scm.com/book/en/v2/Git-Tools-Reset-Demystified#_git_reset)

## Conclusion

- HEAD points to branch, branch point to the last commit, 
  - so HEAD point the last commit, 
  - when you make HEAD point other commit by using `git reset`, it actually makes current branch point to that commit
- The first thing `reset` will do is move what HEAD points to. This isn’t the same as changing HEAD itself (which is what `checkout` does); `reset` moves the branch that HEAD is pointing to. This means if HEAD is set to the `master` branch (i.e. you’re currently on the `master` branch), running `git reset 9e5e6a4` will start by making `master` point to `9e5e6a4`
- Three Tree: HEAD, index, work tree
- `git reset` will do three things, Move HEAD (update HEAD), Updating the Index, Updating the work tree with `--hard`, 

## 1. The Workflow 

**Git’s typical workflow** is to record snapshots of your project by manipulating these three trees: 

![a](/007-git-reset/a.png)

Let’s visualize git’s typical workflow: say you have a new directory with a single file  `file.txt`  in it. Now we run `git init`, which will create a Git repository with a **HEAD reference** which points to the unborn `master` branch (newly-initialized Git repository with unstaged file  `file.txt: v1` in the working directory):

![b](/007-git-reset/b.png)

Now we want to commit this file, so we first use `git add` to copy content in the **working directory** to the **index**:

![c](/007-git-reset/c.png)

Then we run `git commit`, which saves the contents of the **index** as a permanent snapshot, creates a commit object which points to that snapshot, and updates `master` to point to that commit. (这句话信息量很大, 对比下图看看 `git commit`做了什么, 注意 `master` 是个branch)

![d](/007-git-reset/d.png)

If we run `git status`, we’ll see no changes, because all three trees are the same (三个tree: HEAD, Index, Working Directory). 

Now we want to make a change to that file and commit it. first, we change the file in our **working directory**:

![e](/007-git-reset/e.png)

If we run `git status` right now, we’ll see “Changes not staged for commit”, because that entry differs between the **index** and the **working directory**. Next we run `git add` to stage it into our **index**.

![f](/007-git-reset/f.png)

At this point, if we run `git status`, we will see  “Changes to be committed” because the **index** and **HEAD** differ — that is, our proposed next commit is now different from our last commit. Finally, we run `git commit` to finalize the commit:

![g](/007-git-reset/g.png)

注意看我们的图, 分成两个部分, 第一部分是宏观的, 即可以发现HEAD指向的一直是master branch, 然后master branch随着不断的commit一直向外延伸, 第二部分即为了方便我们理解展示的三棵树的变化细节, 即不停的拷贝对比不同, 

Now `git status` will give us no output, because all three trees are the same again.

Switching branches or cloning goes through a similar process. When you checkout a branch, it changes **HEAD** to point to the new branch ref, populates your **index** with the snapshot of that commit, then copies the contents of the **index** into your **working directory**. 这里的 *"populates your index with..."*可以理解为把新的分支的最新的snapshot的内容拷贝到index即staging area, 也就是说每次你切换分支, 其实也是在三棵树间拷贝...只不过是在一个新的分支上操作, 

## 2. The Role of Reset

The `reset` command makes more sense when viewed in this context.

For the purposes of these examples, let’s say that we’ve modified `file.txt` again and committed it a third time. So now our history looks like this:

![h](/007-git-reset/h.png)

### 2.1. Step 1: Move HEAD

The first thing `reset` will do is move what HEAD points to. This isn’t the same as changing HEAD itself (which is what `checkout` does); `reset` moves the branch that HEAD is pointing to. This means if HEAD is set to the `master` branch (i.e. you’re currently on the `master` branch), running `git reset 9e5e6a4` will start by making `master` point to `9e5e6a4`. 所以`reset`在这一步做的就是移动master分支的指向, 即在同一个分支上的版本穿梭, 注意看下图, 三个tree, 只有HEAD的内容变了, 

![i](/007-git-reset/i.png)

No matter what form of `reset` with a commit you invoke, this is the first thing it will always try to do. With `reset --soft`, it will simply stop there.

Now take a second to look at that diagram and realize what happened: it essentially undid the last `git commit` command. When you run `git commit`, Git creates a new commit and moves the branch that HEAD points to up to it. When you `reset` back to `HEAD~` (the parent of HEAD), you are moving the branch back to where it was, without changing the index or working directory. You could now update the index and run `git commit` again to accomplish what `git commit --amend` would have done (see [Changing the Last Commit](https://git-scm.com/book/en/v2/ch00/_git_amend)).

### 2.2. Step 2: Updating the Index (`--mixed`)

Note that if you run `git status` now you’ll see in green the difference between the index and what the new HEAD is.

The next thing `reset` will do is to update the index with the contents of whatever snapshot HEAD now points to.

![j](/007-git-reset/j.png)

If you specify the `--mixed` option, `reset` will stop at this point. This is also the default, so if you specify no option at all (just `git reset HEAD~` in this case), this is where the command will stop.

Now take another second to look at that diagram and realize what happened: it still undid your last `commit`, but also *unstaged* everything. You rolled back to before you ran all your `git add` and `git commit` commands. 相当于`--mixed`是`git reste`的默认操作且比`--soft`多做一步, 

### 2.3. Step 3: Updating the Working Directory (`--hard`)

The third thing that `reset` will do is to make the working directory look like the index. If you use the `--hard` option, it will continue to this stage.

![k](/007-git-reset/k.png)

根据上图可以发现  `--hard` 把三个tree的内容更改为master分支所指向的snapshot, 对这次我们仅是时master分支指向上一次提交的snapshot, 但这个时候要注意, 如果你的working directory里有修改的内容但还没提交, 那可别用这个, 不然就直接覆盖了... 用`--hard`之前要先想想, 

It’s important to note that this flag (`--hard`) is the only way to make the `reset` command dangerous, and one of the very few cases where Git will actually destroy data. Any other invocation of `reset` can be pretty easily undone, but the `--hard` option cannot, since it forcibly overwrites files in the working directory. In this particular case, we still have the **v3** version of our file in a commit in our Git DB, and we could get it back by looking at our `reflog`, but if we had not committed it, Git still would have overwritten the file and it would be unrecoverable. 

## 3. Reset With a Path

That covers the behavior of `reset` in its basic form, but you can also provide it with a path to act upon. If you specify a path, `reset` will skip step 1, and limit the remainder of its actions to a specific file or set of files. This actually sort of makes sense — HEAD is just a pointer, and you can’t point to part of one commit and part of another. But the index and working directory *can* be partially updated, so reset proceeds with steps 2 and 3.

So, assume we run `git reset file.txt`. This form (since you did not specify a commit SHA-1 or branch, and you didn’t specify `--soft` or `--hard`) is shorthand for `git reset --mixed HEAD file.txt`, which will:

1. Move the branch HEAD points to *(skipped)*.
2. Make the index look like HEAD *(stop here)*.

So it essentially just copies `file.txt` from HEAD to the index.

![l](/007-git-reset/l.png)

This has the practical effect of *unstaging* the file. If we look at the diagram for that command and think about what `git add` does, they are exact opposites.

![m](/007-git-reset/m.png)

This is why the output of the `git status` command suggests that you run this to unstage a file (see [Unstaging a Staged File](https://git-scm.com/book/en/v2/ch00/_unstaging) for more on this).

We could just as easily not let Git assume we meant “pull the data from HEAD” by specifying a specific commit to pull that file version from. We would just run something like `git reset eb43bf file.txt`.

![n](/007-git-reset/n.png)