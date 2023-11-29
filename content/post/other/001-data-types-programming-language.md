---
title: Data Types in Programming Languages
date: 2023-11-28 20:50:06
categories:
 - other
tags:
 - c
 - java
 - golang
 - python
 - javascript
---

Previous post: [Typing in Programming Language - Example - David's Blog](https://davidzhu.xyz/post/other/000-languge-types-practice/)

## 1. Javascript

> As you have know that javascript is a dynamic language from previous, which means the values have types, not variables. 

All types except `Object` define immutable values represented directly at the lowest level of the language. We refer to values of these types as primitive values. 

In JavaScript, the language has different types for storing data, and these types can be categorized into two main categories: **objects** and **primitives**. Among these types, the objects are mutable, which means their values can be modified or changed after they are created. On the other hand, the primitive types are immutable, meaning their values cannot be changed once they are assigned.

### 1.1. Primitive types

| Type                                                         | `typeof` return value | Object wrapper                                               |
| :----------------------------------------------------------- | :-------------------- | :----------------------------------------------------------- |
| [Null](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures#null_type) | `"object"`            | N/A                                                          |
| [Undefined](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures#undefined_type) | `"undefined"`         | N/A                                                          |
| [Boolean](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures#boolean_type) | `"boolean"`           | [`Boolean`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Boolean) |
| [Number](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures#number_type) | `"number"`            | [`Number`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number) |
| [BigInt](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures#bigint_type) | `"bigint"`            | [`BigInt`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/BigInt) |
| [String](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures#string_type) | `"string"`            | [`String`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String) |
| [Symbol](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures#symbol_type) | `"symbol"`            | [`Symbol`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Symbol) |

All primitive types, except [`null`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/null) and [`undefined`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/undefined), have their corresponding object wrapper types, which provide useful methods for working with the primitive values. For example, the [`Number`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number) object provides methods like [`toExponential()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Number/toExponential). 

> All primitive types, except [`null`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/null), can be tested by the [`typeof`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/typeof) operator. `typeof null` returns `"object"`, so one has to use `=== null` to test for `null`.

### 1.2. Object types

Learn more: 

[Objects & Collections in Javascript - David's Blog](https://davidzhu.xyz/post/js/basics/001-javascript-basics/)

[JavaScript data types and data structures - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures)

## 2. Python

Python is a dynamic language which means **the values have types, not variables**. 

















