---
title: JS 继承之 Prototype Chain 的意义
date: 2023-06-21 11:08:32
categories:
  - javascript
  - basics
tags:
  - javascript
---

## 1. JS 对象的特殊行为

在说继承之前, 还要提一下 JS 对象很违反直觉的一个行为, 即属性可以通过对象创建之后赋值自动添加, 举个例子, 

```js
const student = {
  name: 'John',
  study: function () {
      return 'study'
  }
}

console.log(student)  // { name: 'John', study: [Function: study] }
student.age = 99
console.log(student)  // { name: 'John', study: [Function: study], age: 99 }
```

只有尝试读取属性值的时候, 在本对象找不到对应属性(property), 才会去其 prototype 去找, **在赋值里, 若本对象没有该属性, 就会直接为此对象创建新的属性**, 如下:

```js
const person = {
  name: 'Jack',
  sayHello: function () {
    console.log('hello from ' + this.name)
  },
}
// 注意为一个对象赋值prototype的方法是为其属性__proto__赋值, 
const student = {
  age: 13,
  __proto__: person
}

console.log(student.name)     // student没有name属性, 通过prototype chain访问其他对象的name属性
console.log(student)         // { age: 13 }
student.name = 'John'       // 为 student 创建新属性 name
console.log(student.name)  // student 此时已有name属性 直接访问其name属性
console.log(student)      // { age: 13, name: 'John' }
student.sayHello()       // 因student无sayHello函数, 通过prototype chain查找sayHello函数, 找到后, sayHello中的this被替换为student
```

## 2. Prototype Chain 的意义

> Javascript is an object-based language, not a class-based language.

If you know Java or C++, you should be familiar with the inheritance concept. **In this programming paradigm**, a class is a blueprint for creating objects. If you want a new class to reuse the functionality of an existing class, you can create a new class that extends the existing class. This is called **classical inheritance**.

> JavaScript doesn’t use **classical inheritance**. Instead, it uses **prototypal inheritance**. In prototypal inheritance, an object “inherits” properties from another object via the `prototype` linkage.

在 [说说 JS 中的 Prototype](https://davidzhu.xyz/post/js/basics/prototype/) 中提到 JS 的每个对象都有个 prototype 属性, 我们可以通过以下两种方式引用一个对象的 prototype: 

```javascript
const person = {
  name: 'Jack'
}

console.log(person.__proto__)
console.log(Object.getPrototypeOf(person))  // standard way

// [Object: null prototype] {}
// [Object: null prototype] {}
```

prototype chain 的意义正是代替了传统语言中的继承机制, 只不过是对象之间的继承, 而不是类之间, 

```js
const person = {
  name: 'Jack',
  greet: function () {
      // for student.getPrototypeOf(person), this will below will become to:
      // console.log('hello, from ' + student.name)
      console.log('hello, from ' + this.name)
  }
};

const student = {
  study: function () {
      return 'study';\
  },
  __proto__: person
}

console.log(student.name);  //Jack, 访问的是 student prototype 的 name 属性
// studnet.name='John' 相当于为 student 添加了个新的属性 name, 
// 文章上面已经介绍这是JS对象的性质, 有点违反直觉, 
student.name = 'John'; 
console.log(student.name); // John, 访问的是 student 自己的 name 属性

student.greet();  // hello, from John

console.log(student.__proto__);  // { name: 'Jack', greet: [Function: greet] }
console.log(Object.getPrototypeOf(student));  // { name: 'Jack', greet: [Function: greet] }
```

> When trying to access a property of an object, the property will not only be sought on the object but on the prototype of the object, the prototype of the prototype, and so on until either a property with a matching name is found or the end of the prototype chain is reached. [Inheritance and the prototype chain - JavaScript | MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Inheritance_and_the_prototype_chain)

```js
const o = {
  a: 1,
  b: 2,
  // __proto__ sets the [[Prototype]]. It's specified here
  // as another object literal.
  __proto__: {
    b: 3,
    c: 4,
  },
};

// o.[[Prototype]] has properties b and c.
// o.[[Prototype]].[[Prototype]] is Object.prototype (we will explain
// what that means later).
// Finally, o.[[Prototype]].[[Prototype]].[[Prototype]] is null.
// This is the end of the prototype chain, as null,
// by definition, has no [[Prototype]].
// Thus, the full prototype chain looks like:
// { a: 1, b: 2 } ---> { b: 3, c: 4 } ---> Object.prototype ---> null

console.log(o.a); // 1
// Is there an 'a' own property on o? Yes, and its value is 1.

console.log(o.b); // 2
// Is there a 'b' own property on o? Yes, and its value is 2.
// The prototype also has a 'b' property, but it's not visited.
// This is called Property Shadowing

console.log(o.c); // 4
// Is there a 'c' own property on o? No, check its prototype.
// Is there a 'c' own property on o.[[Prototype]]? Yes, its value is 4.

console.log(o.d); // undefined
// Is there a 'd' own property on o? No, check its prototype.
// Is there a 'd' own property on o.[[Prototype]]? No, check its prototype.
// o.[[Prototype]].[[Prototype]] is Object.prototype and
// there is no 'd' property by default, check its prototype.
// o.[[Prototype]].[[Prototype]].[[Prototype]] is null, stop searching,
// no property found, return undefined.
```

然后再看个例子, 

```js
const parent = {
  value: 2,
  method() {
    return this.value + 1;
  },
};

console.log(parent.method()); // 3
// When calling parent.method in this case, 'this' refers to parent

// child is an object that inherits from parent
const child = {
  __proto__: parent,
};
console.log(child.method()); // 3
// When child.method is called, 'this' refers to child.
// So when child inherits the method of parent,
// The property 'value' is sought on child. However, since child
// doesn't have an own property called 'value', the property is
// found on the [[Prototype]], which is parent.value.

child.value = 4; // assign the value 4 to the property 'value' on child.
// This shadows the 'value' property on parent.
// The child object now looks like:
// { value: 4, __proto__: { value: 2, method: [Function] } }
console.log(child.method()); // 5
// Since child now has the 'value' property, 'this.value' means
// child.value instead
```

## 3. Javascript 不存在真正的类

JS 不存在真正的类, 即使是ES6之后的类也不过是个语法糖 (syntactic sugar) 而已, 

```js
class Person {
    constructor(name) {
        this.name = name;
    }
    getName() {
        return this.name;
    }
}

console.log(typeof Person); //function
```


> Unlike other programming languages such as Java and C#, JavaScript classes are syntactic sugar over the **prototypal inheritance**. In other words, ES6 classes are just special functions. But class declarations are not **hoisted** like function declarations. 

[说说 JS 中的 Prototype](https://davidzhu.xyz/2023/06/20/JS/Basics/prototype/)  中提到的 `obj.prototype` 和 `obj.__proto__` 不是一个东西, 当定义一个普通的对象之后 (不是函数) 它们的 `obj.prototype` 是 `undefined`, 而当定义函数之后, 这个函数的`func.prototype`会被自动创建, 并且值为一个空对象`{}`:

```js
const func = function () {
    this.name = 'John';
}
const cap = {
    size: 36,
    price: '30CAD',
}

console.log(func.prototype); //{}
console.log(cap.prototype); //undefined
```

思考下面代码发生了什么:
```js
function Person(name) {
    this.name = name;
}

Person.prototype.getName = function () {
    return this.name;
};

console.log(Person.prototype); // { getName: [Function (anonymous)] }

const john = new Person("John Doe");
console.log(Object.getPrototypeOf(john)); // { getName: [Function (anonymous)] }

console.log(john); // Person { name: 'John Doe' }
console.log(john.getName()); // John Doe
```
第一步发生在定义函数Person时:

1. `Person.prototype` 被创建, 并被赋值为一个空对象`{}`

2. `Person.prototype `对象增加一个函数 `getName()`

此时 `Person.prototype `不再是个空对象, 而是有一个名为`getName`函数的对象`{ getName: [Function (anonymous)] }`

之后三步发生在调用`new Person("John Doe")`时:

3. 新创建空对象`{}`并赋值给john
4. 执行`john.__proto__ = Person.prototype`
5. 执行函数Person, 函数体里的 `this.name = name`变为 `john.name = name`

> 综上: The `john` object is an instance of the `Person` through **prototypal inheritance**. 



参考: https://www.javascripttutorial.net/es6/javascript-class/
