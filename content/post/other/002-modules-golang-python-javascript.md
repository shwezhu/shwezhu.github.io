---
title: Python Golang Javascript中的模块对比以及Python中的__name__
date: 2023-06-14 18:32:30
categories:
  - other
tags:
  - javascript
  - python
  - golang
  - other
---

## Python

Python 中的 Modules 就是源文件, 导入 module 也很简单, 就是 `import + file_name`, 如一个源文件 `foo.py`  就是一个 module, 导入这个 module 也很简单即 `import foo`, 然后通过 `foo.sayHello()` 来调用模块 `foo` 里面的函数或类或变量, 

这里要说个变量 `__name__`, 刚说了导入 module 的方法, 变量 `__name__` 的作用就是当执行此源文件时即 `python foo.py`, `__name__` 的值为 `__main__`, 当我们在另一个源文件如 `test.py` 中导入了 module `foo`, 然后执行 `python test.py`, 此时 `foo.py` 中的 `__name__` 的值为 `foo`, 举例:

`foo.py`:

```python
def say_hello():
    print('Hi, ' + __name__)

if __name__ == "__main__":
    say_hello()
```

`main.py`:

```python
import foo

foo.say_hello()
print(__name__)
```

若执行 `python foo.py`, 则输出为:

```
Hi, __main__
```

若执行 `python main.py`, 输出为:

```
Hi, foo
__main__
```

## Goalng

至于 Golang 中的模块与 package, 只要记住一下几点, 

- package 分为两种, executable 和 non-executable package
- 每个 Golang 的源文件必须属于一个 package, 且必须在第一行声明其 package 归属
- 有 main 函数的那个源文件应该属于 `main` package, 即 executable package, 否则无法执行
- Package 就是一个文件夹, 里面有一些 go 的源文件, 注意哦, 在 python 里 module 就是单个的一个源文件
- module 里面有多个 package, 可以理解为你的项目, 

在 [Stack overflow](https://stackoverflow.com/a/72059294/16317008) 看到一个图很清晰:

![a](/002-modules-golang-python-javascript/a.png)

可以参考: [Golang模块module和包package的使用之导入自定义包 | 橘猫小八的鱼](https://davidzhu.xyz/2023/05/21/Golang/Basics/go-modules/)

## JavaScript

JS的 module 就和 python 很像了, 都是一个源文件, 只是需要显示的 export 变量和函数, 且继 ES6 标准之后又有了新的 export 方法即 ES Modules (旧的为 CommonJS), 具体参考: [ECMAScript vs JavaScript & CommonJS vs ES Modules | 橘猫小八的鱼](https://davidzhu.xyz/2023/06/13/JS/Basics/es-vs-js/)
