---
title: 卷积 Graphical Convolution
date: 2023-05-05 22:04:06
categories:
 - INWK
 - Phys
---

# 1. 不定积分

![001](001-3335443.png)

[分部积分法（integration by parts） - 知乎](https://zhuanlan.zhihu.com/p/41545813)

-----

![002](002.png)

![003](003.png)

再看个例子:

![004](004.png)

[分部积分法[高等数学23]_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1DS4y1D7n5/?vd_source=96c3a39c0ce50f46009a7b1394fbbcf9)

[从∫e^x*sinxdx出发——积分随想（I） - 知乎](https://zhuanlan.zhihu.com/p/32850408)

-----

# 2. 图解法求卷积

卷积有三种求法, 卷积定义式，卷积图解法，卷积移位性质, 这里主要说图解法 Graphical Convolution, 先看看定义式:

![005](005-3344982.png)

其中, 在进行图解法的时候, 我们经常对一个简单的信号图像进行反转, 这个反转也没固定的范围, 比如要求你一定要把图像反转到具体哪, 这个具体位置是需要我们讨论的(判断两个图像是否overlap, 讨论t的范围, 注意是讨论t的范围, 而不是上面定义式中的tao)

因为打不出来tao, 所以这里用x代替tao, 

其实根据定义式也能看出来是什么意思了, f(t-x), 注意这里自变量是x, 过程是: 本来是f(t)然后变成了f(x), 这其实就是换个符号而已, 图像不变, 但若是从f(t)变成了f(-x), 这就是原图像相对y轴反转了, 然后又变成f(-(x-t)), 那这就是图像相对y轴反转后, 还要右移t个单位. 注意哦, 当t<0的时候我们右移t个单位的时候我们的函数图像其实是左移了, 

所以我们做题讨论t的时候, 先把图像相对y反转, 之后再t的取值范围(根据t>0就是右移, t<0就是左移)判断是否overlap, 如当2<t<4时, 两图像重叠, 其实就是动的那个图再反转之后, 右移2-4个单位的时候, 他们又重叠,

举个例子, 下面是两个待卷积函数的图像:

![006](006.png)

你看, 显然g(t)的函数式更简单, 所以我们选择让g(t)变成那个g(t-x), 也就是让g(t)相对y轴反转然后移动讨论, 但是这个g(t)有点特殊, 反转后图像不变, 这时候我们直接考虑t就行了, 上面我们说了t的值不是固定的, 根据实际情况讨论, 判读临界点是否两图像overlap, 如下图, 当t<-2的时候, 即反转后的g(t)向右移动了至少-2个单位, 就成了下图所示的样子, 然后他们没有overlap, 所以讨论下一个临界点, 即-1<t<0, 然后求不定积分, 接着讨论....

![007](007.png)

下面这个视频讲的很好:

{% youtube lnzXrSGWMQE %}

- [「珂学原理」No.90「卷积应该怎么卷」](https://www.youtube.com/watch?v=lnzXrSGWMQE&list=PLYdJCSN8wbG8F08QEPdTdx7FDPH7IGx7P&index=9)

了解更多:

- [最经典的卷积积分题目，完美展现卷积积分图解法_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1TK41127sT/?vd_source=96c3a39c0ce50f46009a7b1394fbbcf9)
- [【信号与系统】卷积的三种求解办法_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1Nr4y117V9/?vd_source=96c3a39c0ce50f46009a7b1394fbbcf9)
