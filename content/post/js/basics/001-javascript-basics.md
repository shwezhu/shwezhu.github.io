---
title: JS对象, 数据类型, 容器介绍
date: 2023-06-20 20:51:31
categories:
  - javascript
  - basics
tags:
  - javascript
---

## JavaScript Objects

在其他语言,如C++,Java, 我理解的对象是一个类的实例(instance), 即对象是和类分不开的, 你想使用一个对象必须要先call一个类的constructor, 且Java则必须需要配合`new`关键字. 可是在JS里面, 类的概念变得模糊了, 我很少用到过`new`, 但又有人说说“JavaScript is designed on a simple object-based paradigm”, I‘m confused now. 

在JS里, 什么是variable, 什么是type, type和object的关系是什么? 什么又是value? 我尝试在迷惑中找出答案:

An object is a collection of properties, and a property is an association between a name (or key) and a value. 对象是属性的集合, 属性呢就是name和value的关联. A cup is an object, with properties. A cup has a color, a design, weight, a material it is made of, etc. The same way, JavaScript objects can have properties, which define their characteristics. 杯子有颜色, 容量等属性, 颜色比如蓝色, 容量1000ml, `蓝色`, `1000ml`就是所谓的value, 这个value有type, 前者蓝色是string, 后者1000是number类型. `颜色=蓝色` 这就是对象的一个属性. 突然感觉JS里的对象更像是其他语言里的类, 只是js的对象没有构造函数, 不能实例化. 

A JavaScript object has properties associated with it. A property of an object can be explained as a variable that is attached to the object. Object properties are basically the same as ordinary JavaScript variables, except for the attachment to objects. 对象的属性就是变量, 也很好理解, 比如`cat.name = 'kitten'`, `const name = 'jack'`, 即变量可以有一个对应的value. 而这个value有其对应的type. 所以接下来看看js中的types. 

## Data Types in JS

类型可以分为两大类 `primitive values` and `objects` (和 Java 相似, Java 的是 [primitive types 和 reference type](https://davidzhu.xyz/post/java/basics/006-variables-vs-references/))

**1. Primitive values** (**immutable datum** represented directly at the lowest level of the language)

+ Boolean type

+ Null type

+ Undefined type

+ Number type: 比如上面例子中, 杯子的property: 容量的value: 1000, 的type就是 Number type

+ BigInt type

+ String type: 比如上面例子中, 杯子的property: 颜色的value: blue, 的type就是 String type

+ Symbol type

**2. Objects** (collections of properties)

而对象本身, 也有类型, 那就是 Object 类型.

到这也算是弄清了其中的关系, object, value, type, variable. 这一切从杯子开始举例, 便可以捋清关系. 变量有type吗? 严格来说没有type, 是变量的value才有type. 对象和变量的关系呢? 变量的value可以是object, 这这是value的type就是Object. 


**下面这个就是js中的object, 希望你看了, 可以理解其中的含义**:
```js
let person = {firstName:"John", lastName:"Doe", age:50, eyeColor:"blue", eat: (food)=>{}};

// or
const person = new Object();
person.firstName = "John";
person.lastName = "Doe";
person.age = 50;
person.eyeColor = "blue";
```

**js 的object长得就很像json,如果改变一下写法**, 所以在以后的学习中不要与json弄混, 尤其是React里面的一个js function`React.createElement()`, 它返回的就是 js object, 可以去`MyNotes/frontend/reactjs/JSX and Babel`的第二段介绍Babel编译器看看.

```js
let person = {
    firstName:"John", 
    lastName:"Doe", 
    age:50, 
    eyeColor:"blue", 
    eat: (food)=>{}
};
```

看到这, 想到上文的一对句话:

> An object is a collection of properties, and a property is an association between a name (or key) and a value. 

## "everything is an object in Javascript", Really? 

No, not everything is an object in JavaScript. Many things that you interact with regularly (`strings`, `numbers`, `booleans`) are **primitives**, not **objects**. Unlike objects, primitive values are immutable. The situation is complicated by the fact that these **primitives do have object wrappers** (String, Number and Boolean); these objects have methods and properties while the primitives do not, but the primitives appear to have methods because JavaScript silently creates a wrapper object when code attempts to access any property of a primitive.

For example, consider the following code:

```js
var s = "foo";
var sub = s.substring(1, 2); // sub is now the string "o"
```

Behind the scenes, `s.substring(1, 2)` behaves as if it is performing the following (approximate) steps:

+ Create a wrapper String object from `s`, equivalent to using `new String(s)`
+ Call the `substring()` method with the appropriate parameters on the `String object` returned by step 1
+ Dispose of the `String` object
+ Return the string (primitive) from step 2.

A consequence of this is that while it looks as though you can assign properties to primitives, it is pointless because you cannot retrieve them:

```js
var s = "foo";
s.bar = "cheese";
alert(s.bar); // undefined
```

This happens because the property is effectively defined on a String object that is immediately discarded.

原文: https://stackoverflow.com/a/9110389/16317008

关于 JS 的数据讨论到这应该差不多了, JS 中的数据类型与传统的很不一样, 比如一般的语言单单一个数字就是 float, int, double, 而 js 只是简单的 number type, 另外还要注意它的 Undefined, Null 等类型, 

另外与 Java 相似, JS 中的值的类型分为 primitive 和对象两类, 相似的点在都有 primitive 类型, 但其primitive 又是 immutable的, Java 则不是, 当然还是 python 牛, 真正的万物皆对象, 即使一个 int 类型也是个对象, 但 python 的 int, string 是 immutable, Java里只有string对象是不可变的, 而 js, number type, string 都不可变, JS 的对象, 感觉就是为 json 而生, 

## JS Collections

JS 里的容器不多, 常用的也就 Array, Map, Object, 至于 Array不用说了, 说一下 Object 和 Map, 挺像的他们, 都是保存的 key value, 区别好似 可以保存的 key 的 type 不同, 对于 Object, key的类型就是 string, 

> The key difference is that Objects only support string and Symbol keys where as Maps support more or less any key type. https://stackoverflow.com/a/37994079/16317008

- The keys of an `Object` are [`Strings`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String) or [`Symbols`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Symbol), where they can be of any value for a `Map`.
- You can get the `size` of a `Map` easily, while you have to manually keep track of size for an `Object`.

These three tips can help you to decide whether to use a `Map` or an `Object`:

- Use maps over objects when keys are unknown until run time, and when all keys are the same type and all values are the same type.
- Use maps if there is a need to store primitive values as keys because object treats each key as a string whether it's a number value, boolean value or any other primitive value.
- Use objects when there is logic that operates on individual elements.

References: [Keyed collections - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Keyed_collections)