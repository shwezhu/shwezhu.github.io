---
title: Python Basics
date: 2023-06-17 22:51:31
categories:
  - python
tags:
  - python
---

## 1. List

### 1.1. Indexing

- right to left, use negative number, start from -1

- left to right, use positive number, start form 0

```python
arr = [1, 2, 3]
print(arr[-1]) # 4
print(arr[0]) # 1
print(arr[-4]) # error: out of range
```

## 2. Dictionary

```python
dict = {'a': 1}
print(dict['b']) # Raise a KeyError
print(dict.get('b', 0)) # Print 0, with a default value 
```

e.g.,

```python
# calculate the frequency of the words
def count_words(word_list):
    word_count = {}
    for word in word_list:
        if word in word_count:
            word_count[word] += 1
        else:
            word_count[word] = 1
    return word_count
  
words = ["apple", "banana", "apple", "cherry", "banana", "apple"]
total, count = count_words(words)
```

## 3. Set

- Duplicates Not Allowed

  - Set items are unordered, unchangeable, and do not allow duplicate values.

- Unordered

  - Set items can appear in a different order every time you use them, and cannot be referred to by index or key.

- Unchangeable
  - Once a set is created, you cannot change its items, but you can remove items and add new items.


```python
# because duplicates not allowed, we can use this nature to remove duplicated words 
def find_missing_words(word_list_1, word_list_2):
    set1 = set(word_list_1)
    set2 = set(word_list_2)
    mis_words = set1 - set2
    return mis_words
```

