---
title: C++构造函数和析构函数的应用RAII
date: 2023-05-16 20:32:04
categories:
 - c++
 - basics
tags:
 - c++
---

在上一节[C++类学习之构造函数](https://davidzhu.xyz/2023/05/15/C++/Basics/constructors/)里介绍了构造函数和member initialization list, 这里介绍一些实际开发中会用的改善代码的方法, 

If you have multiple constructors that have the same functionality, use **delegating constructors** to avoid duplicate code.

```c++
#include <iostream>
#include <string>
#include <string_view>

class Employee {
private:
    int m_id{};
    std::string m_name{};

public:
    Employee(int id=0, std::string_view name=""):
        m_id{ id }, m_name{ name } {
        std::cout << "Employee " << m_name << " created.\n";
    }

    // Use a delegating constructor to minimize redundant code
    Employee(std::string_view name) : Employee{ 0, name }
    { }
};
```

---

Constructors are allowed to call non-constructor member functions (and non-member functions), so a better solution is to use a normal (non-constructor) member function to handle the common setup tasks, like this:

```c++
#include <iostream>

class Foo {
private:
    const int m_value { 0 };
    // setup is private so it can only be used by our constructors
    void setup() {
        // code to do some common setup tasks (e.g. open a file or database)
        std::cout << "Setting things up...\n";
    }
  
public:
    Foo() {
        setup();
    }
    // we must initialize m_value since it's const
    Foo(int value) : m_value { value } {
        setup();
    }
};
```

 The `setup()` function can only assign values to members or do other types of setup tasks that can be done through normal statements (e.g. open files or databases). The `setup()` function can’t do things like bind a member reference or set a const value (both of which must be done on initialization), or assign values to members that don’t support assignment.

---

Resetting a class object, if the class is assignable (meaning it has an accessible assignment operator), we can create a new class object, and then use assignment to overwrite the values in the object we want to reset:

```c++
#include <iostream>

class Foo {
private:
    int m_a{ 5 };
    int m_b{ 6 };
public:
    Foo() { }
    Foo(int a, int b) : m_a{ a }, m_b{ b } {}

    void print() {
        std::cout << m_a << ' ' << m_b << '\n';
    }

    void reset() {
        // create new Foo object, then use assignment to overwrite our implicit object
        *this = Foo{}; 
    }
};

int main() {
    Foo a{ 1, 2 };
    a.reset();
    a.print();
}
```

---

RAII (Resource Acquisition Is Initialization) is a programming technique whereby resource use is tied to the lifetime of objects with automatic duration (e.g. non-dynamically allocated objects). **In C++, RAII is implemented via classes with constructors and destructors.** A resource (such as memory, a file or database handle, etc…) is typically acquired in the object’s constructor (though it can be acquired after the object is created if that makes sense). That resource can then be used while the object is alive. The resource is released in the destructor, when the object is destroyed. The primary advantage of RAII is that it helps prevent resource leaks (e.g. memory not being deallocated) as all resource-holding objects are cleaned up automatically.

```c++
class IntArray {
private:
	int* m_array{};
	int m_length{};

public:
	IntArray(int length) {
		assert(length > 0);

		m_array = new int[static_cast<std::size_t>(length)]{};
		m_length = length;
	}

	~IntArray() {
		// Dynamically delete the array we allocated earlier
		delete[] m_array;
	}
  ...
};
```

The `IntArray` class above is an example of a class that implements RAII -- allocation in the constructor, deallocation in the destructor. `std::string` and `std::vector` are examples of classes in the standard library that follow RAII -- **dynamic memory is acquired on initialization, and cleaned up automatically on destruction**.

原文:

- [13.8 — Overlapping and delegating constructors – Learn C++](https://www.learncpp.com/cpp-tutorial/overlapping-and-delegating-constructors/)

- [13.9 — Destructors – Learn C++](https://www.learncpp.com/cpp-tutorial/destructors/)