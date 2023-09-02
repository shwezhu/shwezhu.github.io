---
title: Git Merge实例分析之fast-forward & three-way merge
date: 2023-04-21 09:44:39
categories:
  - Git
tags:
  - Git
typora-root-url: ../../../static
---
## 总结

- 是否可以 fast-forward 取决于主分支是否在被合并分支的祖先分支上
- git merge 输出提示存在 conflicts 时, 就需要进行 three-way merge
  - 此时在输出中找到存在 conflict 的文件, 手动解决 conflict 后进行 commit: ` git commit -m "fixed conflicts"` 
  - 然后便可安全删除次分支
  - 可以使用 git log 查看提交历史

## 实验

```shell
# 初次在main提交 添加个新功能
$ vi main.c
$ cat main.c
#include<stdio.h>
int main() {
	printf("hello world");
	return 0;
}
$ git add .
$ git commit -m "feat print hello world"
$ git branch
*main

# 二次在main提交 再加个新功能
$ vi main.c 
$ cat main.c
#include<stdio.h>
$ cat main.c 
#include<stdio.h>
int add(int a, int b) {
	return a+b;
}
int main() {
	printf("hello world");
	return 0;
}
$ git add .
$ git commit -m "feat new add function" 

# 第三次在main提交, 加个新功能 故意调用错误函数
$ vi main.c
$ cat main.c 
#include<stdio.h>
int add(int a, int b) {
	return a+b;
}
int main() {
	a = aff(3, 9);
	printf("hello world");
	return 0;
}
$ git add .                            
$ git commit -m "invoke add function"  

# 看上面的输出可以发现我们故意调用错误函数, 于是新建分支issue01去解决这个“bug”
$ git switch -c issue01
```

现在我们的分支结构类似下图(在 [`git branch` ](https://davidzhu.xyz/2023/04/22/Git/Git-Branch/)讲过, 新建的分支`issue01`含有`main`分支已存在的commit history), 

![](/005-git-merge/a.png)

```shell
# 接着上面, 现在在issue01分支上
$ vi main.c 
$ cat main.c 
#include<stdio.h>
int add(int a, int b) {
	return a+b;
}
int main() {
	a = add(3, 9);
	printf("hello world");
	return 0;
}
$ git add .
$ git commit -m "resolved issue01"   

# 注意 如果在切换分支前 你进行了git add .操作, 那你就要进行commit
# 否则git会提示你无法切换分支, 例子如下
$ vi main.c 
$ git add .
$ git switch main 
error: Your local changes to the following files would be overwritten by checkout:
	main.c
Please commit your changes or stash them before you switch branches.
Aborting
```

现在分支结构如下, 

![](/005-git-merge/b.png)

```shell
# 验证一下, 在main分支
$ git log
commit d64cbe30304b1588c489e46573be7a9232609791 (HEAD -> main)
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Sat Apr 22 20:35:05 2023 -0300

    invoke add function

commit 581e0025c3a6e4bc6a3cf8609492e49799ea72dc
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Sat Apr 22 20:32:53 2023 -0300

    feat new add function

commit cc4f3b18ca44f075aa44cb6878a00a3210d1b976
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Sat Apr 22 20:28:56 2023 -0300

    feat print hello world
    
# 在issue01分支执行git log
$ git log
commit 6affe5fe6ffebed30ca756b41b361c9cae73bdbe (HEAD -> issue01)
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Sat Apr 22 20:54:57 2023 -0300

    test override

commit 5067731eacd6d00744a3596b86ff17457e43af1c
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Sat Apr 22 20:44:38 2023 -0300

    resolved issue01

commit d64cbe30304b1588c489e46573be7a9232609791 (main)
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Sat Apr 22 20:35:05 2023 -0300

    invoke add function

commit 581e0025c3a6e4bc6a3cf8609492e49799ea72dc
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Sat Apr 22 20:32:53 2023 -0300

    feat new add function

commit cc4f3b18ca44f075aa44cb6878a00a3210d1b976
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Sat Apr 22 20:28:56 2023 -0300

    feat print hello world

```

在`main`新建另一个分支`hotfix`,  并修改源文件, 然后进行一个commit

```shell
$ git switch main   
$ git switch -c hotfix
$ vi main.c 
$ git add .
$ git commit -m "delete hello wrld"
```

然后分支结构如下图, 

![](/005-git-merge/c.png) 

`hotfix`分支已经完成了它的任务, 我们现在跳到`main`分支然后merge一下, 

```shell
$ git switch main
# 根据输出知是 Fast-forward merge
$ git merge hotfix
Updating d64cbe3..8c9302c
Fast-forward
 main.c | 1 -
 1 file changed, 1 deletion(-)
$ git log
commit 8c9302c00cd0699daf38834e8d3919abd1ab4993 (HEAD -> main, hotfix)
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Sat Apr 22 21:29:52 2023 -0300

    delete hello wrld

commit d64cbe30304b1588c489e46573be7a9232609791
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Sat Apr 22 20:35:05 2023 -0300

    invoke add function
...
...
```

merge `hotfix`后, 连带着commit历史一起merge了, 现在结构如下:

![](/005-git-merge/d.png)

现在可以安全删除`hotfix`分支了, 

```shell
$ git branch -d hotfix
Deleted branch hotfix (was 8c9302c).
```

现在结构如下:

![](/005-git-merge/e.png)

假设bug修好了, 准备把分支`issue01`合并到分支`main`上, 如下:

```shell
$ git merge issue01 
Auto-merging main.c
CONFLICT (content): Merge conflict in main.c
Automatic merge failed; fix conflicts and then commit the result.

$ cat main.c 
#include<stdio.h>
int add(int a, int b) {
	return a+b;
}
int main() {
<<<<<<< HEAD
	a = aff(3, 9);
=======
	a = add(3, 9);
	printf("hello world");
>>>>>>> issue01
	return 0;
}
```

合并失败了, 需要手动解决conflicts, 这次失败而上次合并`hotfix`分支并没有失败的的原因是`main`没有在分支`issue01`的祖先分支上, **而`main`在`hotfix`的祖先分支上(类似下图, `main`和`issue1`没在一条线上), 所以可以进行fast-forward合并`hotfix`分支**, 但合并分支`issue01`的时候却不能进行fast-forward合并. 

![](/005-git-merge/f.png)

> This looks a bit different than the `hotfix` merge you did earlier. In this case, your development history has diverged from some older point. Because the commit on the branch you’re on isn’t a direct ancestor of the branch you’re merging in, Git has to do some work. In this case, Git does a simple **three-way merge, using the two snapshots pointed to by the branch tips and the common ancestor of the two**.

不能 fast-forward 合并就需要 three-way merge, 手动解决冲突再提交后大致结构如下图所示:

![](/005-git-merge/g.png)

我们手动修改conflicts内容后进行提交, 

```shell
$ vi main.c
$ git add .
$ git commit -m "fixed conflicts"
```

然后我们就可以安全地删除分支`issue01`,  然后查看log发现, 所有的commit历史都跑到了`main`分支上, 

```shell
$ git branch -d issue01
$ git log
commit 4f4cd865cb03caff3ae89191ce8aa79d2e805ba4 (HEAD -> main)
Merge: 8c9302c 6affe5f
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Sat Apr 22 22:09:19 2023 -0300

    fixed conflicts

commit 8c9302c00cd0699daf38834e8d3919abd1ab4993
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Sat Apr 22 21:29:52 2023 -0300

    delete hello wrld

commit 6affe5fe6ffebed30ca756b41b361c9cae73bdbe
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Sat Apr 22 20:54:57 2023 -0300

    test override

commit 5067731eacd6d00744a3596b86ff17457e43af1c
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Sat Apr 22 20:44:38 2023 -0300

    resolved issue01

commit d64cbe30304b1588c489e46573be7a9232609791
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Sat Apr 22 20:35:05 2023 -0300

    invoke add function

commit 581e0025c3a6e4bc6a3cf8609492e49799ea72dc
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Sat Apr 22 20:32:53 2023 -0300

    feat new add function

commit cc4f3b18ca44f075aa44cb6878a00a3210d1b976
Author: Shaowen Zhu <shaowenzhu@dal.ca>
Date:   Sat Apr 22 20:28:56 2023 -0300

    feat print hello world
```

参考:

- [Git Branching - Basic Branching and Merging](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging)

