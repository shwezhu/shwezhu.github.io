---
title: 不定积分和卷积 Graphical Convolution - 课堂笔记
date: 2023-05-05 22:04:08
categories:
 - INWK
 - Phys
---

## 1. 不定积分 

![001](001-3335443.png)

注意区分复合函数求导, 求不定积分步骤: 

1. 选出 `u` 和 `v`, 求出 `du`, `dv`, 选择的时候要考虑 `v` 的原函数好不好找, 
2. 再根据以上公式, 带入  `u`, `v`,  `du`, `dv`,

![a](a.png)

-----

![002](002.png)

![003](003.png)

再看个例子:

![004](004.png)

-----

## 2. 图解法求卷积

卷积有三种求法, 卷积定义式，卷积图解法，卷积移位性质, 这里主要说图解法 Graphical Convolution, 先看看定义式:

![005](005-3344982.png)

其中, 在进行图解法的时候, 我们经常对一个简单的信号图像进行反转, 这个反转也没固定的范围, 比如要求你一定要把图像反转到具体哪, 这个具体位置是需要我们讨论的(判断两个图像是否overlap, 讨论t的范围, 注意是讨论t的范围, 而不是上面定义式中的tao)

**打不出来tao所以下文用`x`代替tao,** 接下来我们利用图像分析一下上面公式中的 `f(t-x)`是 `f(t)` 怎么平移得到的 *(`f(t-x)` 中的 `x` 是 `tao` )*,  具体可以分成如下三步: 

首先 `f(t)` -> `f(x)`, 这就是换个符号, 图像不变, 

第二步 `f(x)`  -> `f(-x)`, 这就是原图像相对y轴反转了, 

第三步 `f(-x)` ->  `f(-(x-t))`,  这就是图像相对y轴反转后, 还要右移 t 个单位. 注意, 当 t<0 的时, 右移 t 个单位函数图像其实是左移了, 

根据以上, 做题的时候先把图像相对 y 反转, 形成 `f(x)`  -> `f(-x)`, 之后再根据 t 的取值范围 (根据t>0就是右移, t<0就是左移) 判断是否overlap, 即上面的第三步  `f(-x)` ->  `f(-(x-t))`, 举例, 下面是两个待卷积函数的图像:

![006](006.png)

你看, 显然g(t)的函数式更简单, 所以我们选择让g(t)变成那个g(t-x), 也就是让g(t)相对y轴反转然后移动讨论, 但是这个g(t)有点特殊, 反转后图像不变, 这时候我们直接考虑t就行了, 上面我们说了t的值不是固定的, 根据实际情况讨论, 判读临界点是否两图像overlap, 如下图, 当t<-2的时候, 即反转后的g(t)向右移动了至少-2个单位, 就成了下图所示的样子, 然后他们没有overlap, 所以讨论下一个临界点, 即-2<t<0, 然后求不定积分, 接着讨论....

![007](007.png)

看个完整的例子:

![b](b.png)

![c](c.png)

下面这个视频讲的很好:

{% youtube lnzXrSGWMQE %}

参考: 

- [分部积分法（integration by parts） - 知乎](https://zhuanlan.zhihu.com/p/41545813)
- [xlnx的不定积分 - 知乎](https://zhuanlan.zhihu.com/p/447504951)
- [分部积分法[高等数学23]_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1DS4y1D7n5/?vd_source=96c3a39c0ce50f46009a7b1394fbbcf9)
- [从∫e^x*sinxdx出发——积分随想（I） - 知乎](https://zhuanlan.zhihu.com/p/32850408)

- [珂学原理 No.90 卷积应该怎么卷](https://www.youtube.com/watch?v=lnzXrSGWMQE&list=PLYdJCSN8wbG8F08QEPdTdx7FDPH7IGx7P&index=9)

- [最经典的卷积积分题目，完美展现卷积积分图解法_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1TK41127sT/?vd_source=96c3a39c0ce50f46009a7b1394fbbcf9)
- [【信号与系统】卷积的三种求解办法_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1Nr4y117V9/?vd_source=96c3a39c0ce50f46009a7b1394fbbcf9)
