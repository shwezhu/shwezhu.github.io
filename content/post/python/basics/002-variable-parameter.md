---
title: Python不定长参数
date: 2023-06-06 22:51:26
categories:
  - Python
tags:
  - Python
---

### 1. 四种 argument 类型

Python 参数类型有四种:

1. Default argument
2. Keyword arguments (named arguments)
3. Positional arguments
4. Arbitrary arguments (variable-length arguments `*args` and `**kwargs`)

### 2. parameters vs arguments

首先分清 parameters 和 arguments 的区别: 

![a](/002-variable-parameter/a.png)

### 3. Positional arguments vs Keyword arguments

Positional arguments 有点迷, 但也是我们最经常用的, 就是当我们调用函数不指定参数名, 如下面这个函数:

```python
def add(lhs, rhs):
  ...
```

有很多种调用该函数的方法,  如最常见的 `add(10, 20)`, 或者 `add(lhs=10, rhs=20)`, 或者你还可以 `add(10, rhs=20)`, 

对于`add(10, 20)` 里面的`10`, `20` 就是两个 Positional arguments, 

对于 `add(lhs=10, rhs=20)`, `lhs=10` 和` rhs=20`就是两个 Keyword arguments, 

对于 `add(10, rhs=20)`, `10` 是 Positional arguments, `rhs=20` 是 Keyword arguments, 

![b](/002-variable-parameter/b.png)

### 4. Arbitrary positional arguments (`*args`)

We can pass multiple arguments to the function. Internally all these values are represented in the form of a [tuple](https://pynative.com/python-tuples/). 

```python
def percentage(sub1, sub2, sub3):
    avg = (sub1 + sub2 + sub3) / 3
    print('Average', avg)

percentage(56, 61, 73)
```

This function works, but it’s limited to only three arguments. 

```python
# function with variable-length arguments
def percentage(*args):
    sum = 0
    for i in args:
        # get total
        sum = sum + i
    # calculate average
    avg = sum / len(args)
    print('Average =', avg)

percentage(56, 61, 73)
```

### 5. Arbitrary keyword arguments (**kwargs)

与 arbitrary positional arguments 不同, arbitrary keyword arguments 使用 `dictionary` 存储多个被传入的 keyword arguments, 

```python
# function with variable-length keyword arguments
def percentage(**kwargs):
    sum = 0
    for sub in kwargs:
        # get argument name
        sub_name = sub
        # get argument value
        sub_marks = kwargs[sub]
        print(sub_name, "=", sub_marks)

# pass multiple keyword arguments
percentage(math=56, english=61, science=73)
```

输出:

```
math = 56
english = 61
science = 73
```

看源码的时候学到一些技巧, 说一下, 这是部分代码:

```python
    def __prepare_create_request(
        cls,
        api_key=None,
        api_base=None,
        api_type=None,
        api_version=None,
        organization=None,
        **params,
    ):
        deployment_id = params.pop("deployment_id", None)
        engine = params.pop("engine", deployment_id)
        model = params.get("model", None)
        timeout = params.pop("timeout", None)
        stream = params.get("stream", False)
        headers = params.pop("headers", None)
```

上面代码 `model = params.get("model", None)` 的意思: It tries to retrieve the "model" key from the params dictionary, If that key exists, it uses that value, If that key does not exist, it uses the default value None.

对于 `deployment_id = params.pop("deployment_id", None)`: Tries to retrieve the "deployment_id" key from the params dictionary, If it exists, it uses that value and also removes that key,  If it does not exist, it uses the default value None. 

另外, 可以看到此函数`__prepare_create_request()`, 前半部分是一些有默认值的参数, 后面因为一些不那么主要的参数直接写成了arbitrary keyword arguments, 然后最后在函数体里遍历查找, 这么写主要是为了更好的 Readability, 即用户看到这个函数 至少知道要传什么参数, 如果函数写成 `def __prepare_create_request(cls, **params):`, 那用户也不知道具体怎么调用了, 

参考:

- [Python Function Arguments [4 Types] – PYnative](https://pynative.com/python-function-arguments/)
- [Dictionary - Python](https://docs.python.org/3/tutorial/datastructures.html)