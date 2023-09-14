---
title: Git Push with force Flag
date: 2023-09-14 10:00:23
categories:
  - git
tags:
  - git
---

## 1. `git push -f` overwrites remote repo

The commit history on my local and remote repo are same:

```
second commit
first commit
```

I added a file on github which means there is another new commit history on remote repo which is different form the commit history of my local repo. 

Commit history on remote repo:

```
create docs.md
second commit
first commit
```

Files on remote repo:

```
README.md
main.c
docs.md
```

I made some modifications on local repo and make a commit. 

Commit history on local repo:

```
third commit
second commit
first commit
```

Files on local repo:

```
README.md
main.c
```

Now when I try to push my local changes to github:

```
$ git push origin master
To github.com:shwezhu/test_repo.git
 ! [rejected]        master -> master (fetch first)
error: failed to push some refs to 'github.com:shwezhu/test_repo.git'
hint: Updates were rejected because the remote contains work that you do
hint: not have locally. This is usually caused by another repository pushing
hint: to the same ref. You may want to first integrate the remote changes
hint: (e.g., 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

This happens because the commit history of the master branch in local and remote repo are different. 

One way to slolve this is to fetch the remote and merge the changes (commit history will be merged too), then push will succeed. Learn more: [Push on Github get Rejected - Solved - David's Blog](https://davidzhu.xyz/post/git/practice/001-rejected-push-fix-conflicts/)

Another way is to use `git push -f` but this will overwirte your remote repo, which means the commit history and the work place will be overwritten. After use this command, the remote repo's commit history will looks exactly like the local:

```shell
third commit
second commit
first commit
```

And the file `docs.md` will miss, **use `git push -f` carefully, it's dangerous.** 

## 2. 