---
title: Python 基础
date: 2023-06-17 22:51:31
categories:
  - Python
tags:
  - Python
---

关于dict

```python
dict = {'a': 1}

# This will raise a KeyError
print(dict['b'])

# Using .get() with a default value 
print(dict.get('b', 0)) # Print 0
```


