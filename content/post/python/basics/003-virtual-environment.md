---
title: Python创建虚拟环境以及'Python -m'和‘if __name__ == "__main__"’
date: 2023-05-09 20:12:40
categories:
  - python
tags:
  - python
---

### **查看python环境**

```shell
ls /usr/bin/python* & ls /usr/local/bin/python*
```

### **`/usr/bin`, `usr/local/bin`**

> `/usr/bin` belongs to the system. Mess with it at your peril.
> `/usr/local/bin` is yours to fool with; if you mess something up in there, you can trash `/usr/local` and the system will chug along just fine. If you trash `/usr/bin`, you'll probably end up reinstalling the OS.

### **Environment Variable`$path`**

> The `PATH` environment variable is an essential component of any Linux system. If you ever use the command line at all, the system is relying on the `PATH` variable to find the location of the commands you are entering.

```shell
echo $path
/opt/homebrew/bin /opt/homebrew/sbin /usr/local/bin /usr/bin /bin /usr/sbin /sbin
```

More about `path`: https://linuxconfig.org/linux-path-environment-variable

---

### **Command `python -m <module-name>`**

```shell
python3 -m notebook
python3 -m pip ...

# 没有 -m 将会报错
python3 notebook
// /Library/Developer/CommandLineTools/usr/bin/python3: can't open file '/Users/shaowen/notebook': [Errno 2] No such file or directory

python pip 
// python: can't open file '/Users/PyCharm/pythonProject/pip': [Errno 2] No such file or directory
```

What does `-m` in `python -m pip install <package>` mean? or while upgrading pip using `python -m pip install --upgrade pip`. What is difference when just running `pip install`.

> -m: run library module as a script (terminates option list)

```bash
python3 main.py // 正常执行
python3 -m main // 正常执行
python3 main // 报错
python3 -m main.py // 提示建议 去掉后缀
```

---

### **`if __name__ == "__main__"`**

> This is useful because you **do not** want this code block to run when importing into other files, but you **do** want it to run when invoked from the command line.

两个文件 `main.py`, `cat.py`:

```python
//cat.py:
if __name__ == "__main__":
    print('mow~')

//main.py:
import cat
print('hello')
```

命令行执行:
```shell
python main.py
hello
# 如果把cat.py里的第一行去掉, 执行main.py则会输出
python main.py
mow~
hello
```

---

### **Create Virtual Environment**

**venv** (for Python 3) and **virtualenv** (for Python 2) allow you to manage separate package installations for different projects. They essentially allow you to create a “virtual” isolated Python installation and install packages into that virtual installation. When you switch projects, you can simply create a new virtual environment and not have to worry about breaking the packages installed in the other environments. It is always recommended to use a virtual environment while developing Python applications.

To create a virtual environment, go to your project’s directory and run `venv`. If you are using Python 2, replace venv with `virtualenv` in the below commands.

```shell
python3 -m venv env
source env/bin/activate
```
You can confirm you’re in the virtual environment by checking the location of your Python interpreter:

```shell
which python
/Users/shaowen/Codes/Terminal/economic/env/bin/python
(env) 

python3 -m pip list
Package    Version
---------- -------
pip        21.2.4
setuptools 58.0.4
```

Use this command to install packages: 
```shell
python3 -m pip install xxx
python3 -m pip freeze > requirements.txt
```

https://packaging.python.org/en/latest/guides/installing-using-pip-and-virtual-environments/

### **`pip uninstall xxx` doesn't remove dependencies**

use `pip-autoremove` to remove a package plus unused dependencies.
```shell
# install pip-autoremove
pip install pip-autoremove
# remove "somepackage" plus its dependencies:
pip-autoremove xxx -y
```

https://stackoverflow.com/a/10284948/16317008
