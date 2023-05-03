---
title: 正则表达式之关于'(? … )'的困惑
date: 2023-05-03 00:52:00
categories:
 - Regex
tags:
 - Regex
---

最初想筛选以`sh`结尾但前面吗没有`.`的文件, 其实很简单, 就是`sh`前面没有`.`, 对应的Regex为`(?<!\.)sh$`, 但是! 刚开始不知道`(?!)`,`(?=)`,`(?<!)`这种写法规则, 就在想用逻辑与写出以`sh`结尾的字符但不以`.sh`结尾, 但这本身就矛盾啊, 以`.sh`结尾本身就是以`sh`结尾啊,,, 研究了俩小时, 太菜了,,,, 又快凌晨一点了, 

在[StackOverflow](https://stackoverflow.com/a/2973495/16317008)看到一个好的回答, 放到这, 就讨论一下这几个表达式, 

 Given the string `foobarbarfoo`:

```shell
bar(?=bar)     finds the 1st bar ("bar" which has "bar" after it)
bar(?!bar)     finds the 2nd bar ("bar" which does not have "bar" after it)
(?<=foo)bar    finds the 1st bar ("bar" which has "foo" before it)
(?<!foo)bar    finds the 2nd bar ("bar" which does not have "foo" before it)
```

You can also combine them:

```shell
(?<=foo)bar(?=bar)    finds the 1st bar ("bar" with "foo" before it and "bar" after it)
```

使用这种lookaround句型的时候要注意上面的写法, 即`(?!bar)`这种就是用来指定某个单词后**不含有**什么的, 而你想用某个单词前不含有指定字符, 那就用`(?<!foo)`这种, 别用`(?!bar)bar`, 这样你是不会匹配对的, 你可以试试, 

然后还有一个重要的点如下:

>  In the meantime, if there is one thing you should remember, it is this: **a lookahead or a lookbehind does not "consume" any characters on the string**. This means that after the lookahead or lookbehind's closing parenthesis, the regex engine is left standing on the very same spot in the string from which it started looking: it hasn't moved. From that position, then engine can start matching characters again. 

即这些Lookaround只是用来检查check的, 像是个附加条件, 然后检查到符合条件(`(?!bar)`)的部分后, 将依然从那个部分开始继续往后匹配, 即Lookaround是不消耗字符串的, 举个例子就很容易理解了, 

```shell
$ printf "foobarbarfoo" | grep -P 'bar(?=bar)'
```

上面这个命令得到的结果为foo**bar**barfoo, 即筛选出来了bar, 然后下面这个命令得到的结果是foo**barb**arfoo

```shell
$ printf "foobarbarfoo" | grep -P 'bar(?=bar)b'
```

可以看到, Regex引擎匹配到bar后面还有个bar后, 并没有从foo开始继续匹配, 而是依然从第一个bar后匹配, 然后匹配到了字符`b`, 也就是说`(?=bar)`并没消耗掉第二个`bar`, 按照其他的巨型, 比如

```shell
$ printf "foobarbarbfoo" | grep -P 'bar(bar|123)b'       
$ printf "foobar1231foo" | grep -P 'bar(bar|123)1'
```

上面这俩语句得到的结果分别是foo**barbarb**foo, foo**bar1231**foo, 可以看到`(bar|123)`消耗了字符, Regex引擎的指针直接移动到了最后一个`b`那进行匹配, 而不是倒数第二个`b`, 

参考:

- [Advanced Regex Tutorial—Regex Syntax](https://www.rexegg.com/regex-disambiguation.html#lookarounds)

- [lookaround - Regex lookahead, lookbehind and atomic groups - Stack Overflow](https://stackoverflow.com/questions/2973436/regex-lookahead-lookbehind-and-atomic-groups)
