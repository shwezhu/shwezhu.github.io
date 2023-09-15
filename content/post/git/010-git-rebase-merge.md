---
title: git merge vs git rebase
date: 2023-09-15 10:20:23
categories:
  - git
tags:
  - git
---

In Git, there are two main ways to integrate changes from one branch into another: the `merge` and the `rebase`. 

## 1. fast-forward vs three-way merge

There are two type of merge:

- three-way merge, 
  - happens when the branches have diverged
  - will result a new commit in commit history
- fast-forward merge, 
  - happens when there is a liner structure in the commit history
  - won't result new commit
  - can be suppressed with the `--no-ff` option
  - we usually prevent fast-forward merge, because it will lose infomation

On `main` branch:

```shell
* commit 2220b67f9c8ccf5f47e51bff7bd3a3fca6e141b6 (HEAD -> main)
      main: Fri 15 Sep 2023 11:47:54 ADT
```

On `fixbug` branch:

```shell
* commit 0096a2dfa2b4e4c40011213b6cce12ee73833ca9 (HEAD -> fixbug)
|     fixbug: Fri 15 Sep 2023 11:48:53 ADT
| 
* commit fd900fa0c05632757f45fd6fee236eb84c99bb94
|     fixbug: Fri 15 Sep 2023 11:48:27 ADT
| 
* commit 2220b67f9c8ccf5f47e51bff7bd3a3fca6e141b6 (main)
      main: Fri 15 Sep 2023 11:47:54 ADT
```

The commit structure looks like this:

```shell
      A---B fixbug
     /
...--E master
```

Merge `fixbug` into `main` branch (fast-forward):

```shell
$ git switch main
$ git merge fixbug 
Updating 2220b67..0096a2d
Fast-forward
...
$ git log --graph
* commit 0096a2dfa2b4e4c40011213b6cce12ee73833ca9 (HEAD -> main, fixbug)
|     fixbug: Fri 15 Sep 2023 11:48:53 ADT
| 
* commit fd900fa0c05632757f45fd6fee236eb84c99bb94
|     fixbug: Fri 15 Sep 2023 11:48:27 ADT
| 
* commit 2220b67f9c8ccf5f47e51bff7bd3a3fca6e141b6
      main: Fri 15 Sep 2023 11:47:54 ADT
```

**Commit history of all branches** looks like this now (and you can delete `fixbug`branch safely now):

```shell
	  A---B fixbug
	 / 
...E---A---B main
```

Assume we didn't do a fast-forward merge instead we do a three-way merge here:

```shell
      A---B fixbug
     /
...--E main
```

```shell
$ git switch main
$ git merge --no-ff fixbug
Merge made by the 'ort' strategy.
$ git log --graph         
*   commit 52204f34cf6d0bdd6456c8e4830e0948b3c8b308 (HEAD -> main)
| \     Merge branch 'fixbug'
| | 
| * commit 0096a2dfa2b4e4c40011213b6cce12ee73833ca9 (fixbug)
| |     fixbug: Fri 15 Sep 2023 11:48:53 ADT
| | 
| * commit fd900fa0c05632757f45fd6fee236eb84c99bb94
| /      fixbug: Fri 15 Sep 2023 11:48:27 ADT
| 
* commit 2220b67f9c8ccf5f47e51bff7bd3a3fca6e141b6
      main: Fri 15 Sep 2023 11:47:54 AD
```

Now **the commit history of branch `main`** looks like this (there is a new commit `F` for merge, you can delete `fixbug` safely now):

```shell
      A---B fixbug
     /   /
...--E---F main
```

{{% youtube "zOnwgxiC0OA" %}}

## 2. git rebase

> *The Golden Rule of Rebasing reads: “Never rebase while you’re on a public branch.”*
>
> Source: https://www.gitkraken.com/blog/golden-rule-of-rebasing-in-git

On `main` branch:

```shell
* commit 41bc8e89e60d75e21e034aaabcbd20103a61fca4 (HEAD -> main)
|     main: Fri 15 Sep 2023 13:01:02 ADT
| 
* commit 2220b67f9c8ccf5f47e51bff7bd3a3fca6e141b6
      main: Fri 15 Sep 2023 11:47:54 ADT
```

On `fixbug` branch:

```shell
* commit 0096a2dfa2b4e4c40011213b6cce12ee73833ca9 (HEAD -> fixbug)
|     fixbug: Fri 15 Sep 2023 11:48:53 ADT
| 
* commit fd900fa0c05632757f45fd6fee236eb84c99bb94
|     fixbug: Fri 15 Sep 2023 11:48:27 ADT
| 
* commit 2220b67f9c8ccf5f47e51bff7bd3a3fca6e141b6
      main: Fri 15 Sep 2023 11:47:54 AD
```

Now the **commit history of all branches** looks like this:

```shell
      A---B fixbug
     /
...--E---F main
```

Go to `main` branch and make rebase. 

```shell
$ git switch main
$ git rebase fixbug
Successfully rebased and updated refs/heads/main.
```

Check the log, you can see, these two branches combined but the commit histroy structure is linear:

```shell
* commit 918260ae4f0b7f7d573a9a640ce380ea0f861a6a (HEAD -> main)
|     main: Fri 15 Sep 2023 13:01:02 ADT
| 
* commit 0096a2dfa2b4e4c40011213b6cce12ee73833ca9 (fixbug)
|     fixbug: Fri 15 Sep 2023 11:48:53 ADT
| 
* commit fd900fa0c05632757f45fd6fee236eb84c99bb94
|     fixbug: Fri 15 Sep 2023 11:48:27 ADT
| 
* commit 2220b67f9c8ccf5f47e51bff7bd3a3fca6e141b6
      main: Fri 15 Sep 2023 11:47:54 ADT
```

Now **the commit history of `main` branch** looks like this (and you can delete `fixbug` branch):

```shell
      A---B---F' main
     /
...--E
```

As you can see, rebase just make a fast-forward merge happen even the branches has diverged. 

And note that the `F'` mean it's a copy of original commit `F` (git will do this internally), this is why we should not use rebase on a shared branch, `main` for example, because `rebase` will "change" the commit history of branch `main`. 

{{% youtube "zOnwgxiC0OA" %}}

## 3. git rebase vs merge

- Merge preserves commit history. 
  - Use merge on a public branch. 
- Rebase rewrites (makes copy) history.
  - Use rebase on a private branch to catch up update form remote. 
  - Why rebase rewrite commit history: https://youtu.be/zOnwgxiC0OA?si=CwbvoPI35pHgJ1pn&t=401

> Note that we say use rebase on a private branch means we can use the command`git rebase master` on a private, please don't use `git rebase fixissue` on `master` branch which apparently is a publick branch. 
>
> Learn more: https://youtu.be/zOnwgxiC0OA?si=CwbvoPI35pHgJ1pn&t=401

{{% youtube "CRlGDDprdOQ" %}}

References:

- [Learn Git Rebase in 6 minutes // explained with live animations!](https://youtu.be/f1wnYdLEpgI?si=QTeScOvk_yNzzud-)
- [Git MERGE vs REBASE: The Definitive Guide](https://youtu.be/zOnwgxiC0OA?si=zUXhbnfTX7Ve8BiJ)
- [Git MERGE vs REBASE](https://youtu.be/CRlGDDprdOQ?si=zSduuwUYe6YpoVUG)