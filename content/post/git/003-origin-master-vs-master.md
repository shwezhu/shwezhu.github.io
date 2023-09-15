---
title: master vs origin/master vs remotes/origin/master
date: 2023-08-16 09:42:50
categories:
  - git
tags:
  - git
---

Take a clone of a remote repository and run `git branch -a` (to show all the branches git knows about). It will probably look something like this:

```shell
* master
  remotes/origin/HEAD -> origin/master
  remotes/origin/master
```

Here, `master` is a branch in the local repository. `remotes/origin/master` is a branch named `master` on the remote named `origin`. You can refer to this as **either** `origin/master`, as in:

```
git diff origin/master..master
```

You can also refer to it as `remotes/origin/master`:

```
git diff remotes/origin/master..master
```

These are just two different ways of referring to the same thing (incidentally, both of these commands mean "show me the changes between the remote `master` branch and my `master` branch).

`remotes/origin/HEAD` is the `default branch` for the remote named `origin`. This lets you simply say `origin` instead of `origin/master`.

Source: https://stackoverflow.com/a/10588561/16317008