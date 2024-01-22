---
title: Exception Handling & Expensive or Not Python
date: 2023-11-24 09:37:26
categories:
  - python
tags:
  - python
typora-root-url: ../../../../static
---

## 1. Basics concepts

Try to understand the exception information (*Traceback (most recent call last)*) :

```python
def foo():
    print(10 * (1 / 0))

def main():
    foo()

if __name__ == "__main__":
    main()

Traceback (most recent call last):
  File "main.py", line 10, in <module>
    main()
  File "main.py", line 6, in main
    foo()
  File "main.py", line 2, in foo
    print(10 * (1 / 0))
ZeroDivisionError: division by zero
```

As you can see The last line of the error message indicates what happened: `print(10 * (1 / 0))`. 

> Errors detected during execution are called *exceptions*. [Errors and Exceptions — Python 3.12.0](https://docs.python.org/3/tutorial/errors.html)

## 2. Types of Exceptions

`BaseException` is the common base class of all exceptions. One of its subclasses, `Exception`, is the base class of all the **non-fatal** exceptions. Exceptions which are not subclasses of `Exception` are not typically handled, because they are used to indicate that the program should terminate. They include `SystemExit`which is raised by `sys.exit()` and `KeyboardInterrupt`which is raised when a user wishes to interrupt the program.

`Exception`can be used as a wildcard that catches (almost) everything. However, it is good practice to be as specific as possible with the types of exceptions that we intend to handle, and to allow any unexpected exceptions to propagate on.

## 3. Handle Exceptions

The most common pattern for handling `Exception` is to **print or log the exception and then re-raise it** (allowing a caller to handle the exception as well):

```python
import sys

try:
    f = open('myfile.txt')
    s = f.readline()
    i = int(s.strip())
except OSError as err:
    print("OS error:", err)
    raise
except Exception as err:
    print(f"Unexpected {err=}, {type(err)=}")
    raise
```

### Predefined clean-up actions

Some objects define standard clean-up actions to be undertaken when the object is no longer needed, regardless of whether or not the operation using the object succeeded or failed. Look at the following example, which tries to open a file and print its contents to the screen.

```python
for line in open("myfile.txt"):
    print(line, end="")
```

The problem with this code is that it leaves the file open for an indeterminate amount of time after this part of the code has finished executing. This is not an issue in simple scripts, but can be a problem for larger applications. The [`with`](https://docs.python.org/3/reference/compound_stmts.html#with) statement allows objects like files to be used in a way that ensures they are always cleaned up promptly and correctly.

```python
with open("myfile.txt") as f:
    for line in f:
        print(line, end="")
```

After the statement is executed, the file *f* is always closed, **even if a problem was encountered while processing the lines**. Objects which, like files, provide predefined clean-up actions will indicate this in their documentation.

## 4. Performance

[performance - How is exception handling implemented in Python? - Stack Overflow](https://stackoverflow.com/questions/66536614/how-is-exception-handling-implemented-in-python):

> I've learned from other SO answers that a try/catch block is [cheaper than an if/else statement](https://stackoverflow.com/a/2522013/1663614) if the exception is expected to be raised rarely, and that [it's the call depth that's important](https://stackoverflow.com/a/36784706/1663614) because filling the stacktrace is expensive. This is probably principally true for all programming languages. 

> If you throw an exception, all functions will be exited back to the point where it finds a `try...catch` block with a matching `catch` type. If your function isn't called from within a try block, the program will exit with an unhandled exception.

Find some discussions, from: [c# - Do try/catch blocks hurt performance when exceptions are not thrown? - Stack Overflow](https://stackoverflow.com/questions/1308432/do-try-catch-blocks-hurt-performance-when-exceptions-are-not-thrown?noredirect=1&lq=1)

> During a code review with a Microsoft employee we came across a large section of code inside a `try{}` block. She and an IT representative suggested this can have effects on performance of the code. In fact, they suggested most of the code should be outside of try/catch blocks, and that only important sections should be checked. The Microsoft employee added and said an upcoming white paper warns against incorrect try/catch blocks.

> try catch blocks have a negligible impact on performance but exception Throwing can be pretty sizable, this is probably where your coworker was confused.

Another disscussion: [java - Is it expensive to use try-catch blocks even if an exception is never thrown? - Stack Overflow](https://stackoverflow.com/questions/16451777/is-it-expensive-to-use-try-catch-blocks-even-if-an-exception-is-never-thrown?noredirect=1&lq=1)

> `try` has almost no expense at all. Instead of doing the work of setting up the `try` at runtime, the code's metadata is structured at compile time such that when an exception is thrown, it now does a relatively expensive operation of walking up the stack and seeing if any `try` blocks exist that would catch this exception. From a layman's perspective, `try` may as well be free. It's actually throwing the exception that costs you - but unless you're throwing hundreds or thousands of exceptions, you still won't notice the cost.

Another post: [What are the effects of exceptions on performance in Java? - Stack Overflow](https://stackoverflow.com/questions/299068/what-are-the-effects-of-exceptions-on-performance-in-java?noredirect=1&lq=1)

> In Java much of the expense of throwing an exception is the time spent gathering the stack trace, which occurs when the exception object is created. The actual cost of throwing the exception, while large, is considerably less than the cost of creating the exception. 
>
> https://stackoverflow.com/a/8024032/16317008

## 5. When to catch

### 5.1. At the lowest possible level

This is the level at which you are integrating with third party code, such as an ORM tool or any library performing IO operations (accessing resources over HTTP, reading a file, saving to the database, you name it). That is, **the level at which you leave your application’s native code** to interact with other components.

The guidelines in this scenario are:

- **Handle only specific exceptions**, such as `SqlTimeoutException` or `IOException`. Never handle a generic exception (of type `Exception`)
- **Handle it only if you have something meaningful to do about it**, such as retries, triggering compensatory actions, or adding more data to the exception (e.g. context variables), and then re-throw it
- **Do not perform logging here**
- **Let all other exceptions bubble up** as they will be handled by the second case

### 5.2. At the highest possible level

This would be the last place where you can handle the exception before it is thrown directly to the user.

Your goal here is to **log the error and forward the details to the programmers** so they can identify and correct the error. Add as much information as possible, record it, and then **show an apology message to the user**, as there’s probably nothing they can do about it, especially if it is a bug in the software.

The guidelines in this second scenario are:

- Handle the generic Exception class
- Add more information from current execution context
- Log the error and notify the programmers
- Show an apology to the user
- Work it out as soon as you can

Learn more, very good explanation: https://stackoverflow.com/a/59511485

## 6. When to throw exceptions

Easier to explain in the context of developing a library. **You should throw when you reached an error and there's nothing more you can do** besides letting the consumer of your APIs know about it, and letting them decide.

Imagine you're the developer of some data access library. When you reach a network error, there's nothing you can do besides throwing an exception. That's an irreversible error from a data access library standpoint.

Learn more, very good explanation: https://stackoverflow.com/a/59511485