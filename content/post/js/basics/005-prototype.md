---
title: 说说 JS 中的 Prototype
date: 2023-06-20 21:41:32
categories:
  - javascript
  - basics
tags:
  - javascript
---

`{}` 就是个空对象, `{}` 然鹅在 Python 里是个 dictionary, 

## 1. Prototype

**Every object** in JavaScript has a built-in property, which is called its `prototype`. The `prototype` is itself an object, so the `prototype` will have its own `prototype`, making what's called a **prototype chain**. The chain ends when we reach a prototype that has `null` for its own prototype. 

> Note: The property of an object that points to its `prototype` is **not** called `prototype`. Its name is not standard, but in practice all browsers use `__proto__`. The **standard way** to access an object's prototype is the `Object.getPrototypeOf()` method. 

关于prototype有一个迷惑的地方, 通过`obj.prototype`访问到的并不是上面我们讨论的prototype, 只能通过`obj.__proto__`和全局函数`Object.getPrototypeOf()`来获取一个对象的`prototype`属性:

```js
const person = {
    name: 'Jack',
    greet: function () {
        return 'Hi, I am' + this.name;
    }
}

console.log(person.prototype)
console.log(person.__proto__)
console.log(Object.getPrototypeOf(person))

// undefined
// [Object: null prototype] {}
// [Object: null prototype] {}
```

根据打印可以看出 `person.prototype`跟`person.__proto__`压根就不是一个东西, 

### 1.1. prototype 的获取与赋值

`obj.__proto__` 不是访问对象 prototype 属性的标准方法, 因为有的browser可能没实现, 所以访问(只读)一般用`Object.getPrototypeOf(student)`, 通过创建该对象的时候为其 `__proto__` 属性赋值的方法给一个对象的 prototype 赋值, 如下: 

```js
const person = {
  name: 'Jack',
  sayHello: function () {
    console.log('hello from ' + this.name)
  },
}

const student = {
  age: 13,
  // Check the assignment here:
  __proto__: person
}

console.log(Object.getPrototypeOf(student))  // { name: 'Jack', sayHello: [Function: sayHello] }

// 或者创建对象后赋值, 
student.__proto__ = person
// 注意若student没有__proto__属性则这里自动为student创建__proto__并赋值, 赋值后我们就可以访问了
// 所以这和上面我们说的不要通过 `obj.__proto__`  访问一个对象的 prototype 并不矛盾
```

## 2. Function is also an Object.

当你打印函数`A.prototype`的时候, 终端打印的是`{}`, 这对花括号代表的是个**空对象(empty object)**. 所以`A.prototype`只是一个空对象, 在定义函数A的时候被创建的. 
```js
var A = [];
A.prototype // undefined
A = function() {}
A.prototype // {} // got created when function() {} was defined
```

> `A.prototype` is TOTALLY DIFFERENT from the `__proto__` property. In our example, `A` now has TWO properties called `prototype` and `__proto__` . This is a big confusion for people. `prototype` and `__proto__` properties are in no way related, they're separate things pointing to separate values.

You may wonder: Why does JavaScript has `__proto__`property created on every single object? Well, one word: **delegation**. When you call a property on an object and the object doesn't have it, then JavaScript looks for the object referenced by __proto__ to see if it maybe has it. If it doesn't have it, then it looks at that object's `__proto__` property and so on...until the chain ends. Thus the name **prototype chain**. 

You may also wonder, why does JavaScript creates a property called `prototype` for a function when you define the function? Because it tries to fool you, yes **fool you** that it works like class-based languages (actually javascript is an object-based language).

```js
A = function() {}

var a1 = new A();
```

We said that all objects in JavaScript have an internal `__proto__` property which points to something (`a1` also has it), whether it's null or another object. What the `new operator` does is that it sets that `__proto__` property to point to the function's `prototype` property. It's basically this:

```js
a1.__proto__ = A.prototype;
```

上面说了`A.prototype`指向的就是个空对象, 所以现在`a1.__proto__`和`A.prototype`相同, 也是空对象. They both point to the same object which was created when this line happened:
```js
A = function() {} // JS: cool. let's also create A.prototype pointing to empty {}
```

假如函数A像下面这样,

```js
var A = function() { this.hey = function() { alert('from A') } };
```
那么执行`var a1 = new A()`的时候, 还会发生一件事, 就是A函数里面的语句都会被执行, 然后`this.hey`变成`a1.hey`:
```js
a1.hey = function() { alert('from A') }
```

综上, `var a1 = new A()`一共做了下面三件事:

1. a totally new empty object is created and assigned to `a1`.
2. `a1.__proto__ = A.prototype`
3. The `function A()` is being executed 但是`this.hey`变成`a1.hey`

Now, let's try to create another object:

```js
var a2 = new A();
```

`a1` and `a2` have two SEPARATE properties named `hey` which point to 2 SEPARATE functions! 所以我们现在有两个重复的函数在两个不同的对象中做了同样的事. 这岂不是浪费代码? 冗余, 如果有1000个对象呢? 

所以为了防止这种冗余产生, `prototype`来救场了, 使用它, 你可以让无数对象共用同一个函数, 有点像c++里面虚函数的意思(emm是吗? 不确定).

```js
var A = function() {}

A.prototype.hey = function() { alert('from prototype') };
```
Now, when you create `a1`, it again goes through all of the 3 steps above, and in step 3, it doesn't do anything, since `function A()` has nothing to execute. And if we do:

```js
a1 = new A();
a.hey;
```

It will see that a1 does not contain `hey` and it will check its `__proto__` property object to see if it has it, which is the case. 

再想想上面的那句话:

We said that all objects in JavaScript have an internal `__proto__` property which points to something (`a1` also has it), whether it's null or another object. What the `new operator` does is that it sets that `__proto__` property to point to the function's `prototype` property. It's basically this:

```js
a1.__proto__ = A.prototype;
```

## 3. 为什么要有 Prototype Chain

假如你要访问一个对象的 name 属性,或者是调用一个对象的函数, 如果这个对象没有你要调用的函数或者要访问的属性, 那就会自动搜索这个对象的prototype(prototype本身也是个对象)的函数和属性, 一直找到prototype chain的末端. ummm,感觉有点熟悉? 是不是想到了java,cpp里的继承机制. 没错, prototype chain这种机制正式帮助javascript实现了对象之间的继承,而不是类之间的继承, 所以它是prototypal inheritance而不是classical inheritance, 具体会放到 [JS 继承之 Prototype Chain 的意义](https://davidzhu.xyz/2023/06/21/JS/Basics/prototypal-inheritance/) 讨论

参考: 

- https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Objects/Object_prototypes
- https://stackoverflow.com/a/34948211/16317008

