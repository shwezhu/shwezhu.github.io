---
title: What is Jar Package in Java
date: 2023-04-25 15:04:48
categories:
 - Java
 - Basics
tags:
 - Java
---

如果有很多`.class`文件，散落在各层目录中，肯定不便于管理。如果能把目录打一个包，变成一个文件，就方便多了。

jar包实际上就是一个zip格式的压缩文件，而jar包相当于目录。如果我们要执行jar包的里面的某个`class`，就可以把jar包放到`classpath`中：

```
java -cp ./hello.jar abc.xyz.Hello
```

这样JVM会自动在`hello.jar`文件里去搜索某个类。

因为jar包就是zip包，所以，直接在资源管理器中，找到正确的目录，点击右键，在弹出的快捷菜单中选择“发送到”，“压缩(zipped)文件夹”，就制作了一个zip文件。然后，把后缀从`.zip`改为`.jar`，一个jar包就创建成功。

假设编译输出的目录结构是这样：

```
package_sample
└─ bin
   ├─ hong
   │  └─ Person.class
   │  ming
   │  └─ Person.class
   └─ mr
      └─ jun
         └─ Arrays.class
```

这里需要特别注意的是，jar包里的第一层目录，不能是`bin`，而应该是`hong`、`ming`、`mr`。如果在Windows的资源管理器中看，应该长这样：

![](a.png)

说明打包打得有问题，JVM仍然无法从jar包中查找正确的class，原因是`hong.Person`必须按`hong/Person.class`存放，而不是`bin/hong/Person.class`。

jar包还可以包含一个特殊的`/META-INF/MANIFEST.MF`文件，`MANIFEST.MF`是纯文本，可以指定Main-Class和其它信息。JVM会自动读取这个MANIFEST.MF文件，如果存在Main-Class，我们就不必在命令行指定启动的类名，而是用更方便的命令：

```shell
java -jar hello.jar
```

在大型项目中，不可能手动编写`MANIFEST.MF`文件，再手动创建zip包。Java社区提供了大量的开源构建工具，例如**Maven**，可以非常方便地创建jar包。

原文: https://www.liaoxuefeng.com/wiki/1252599548343744/1260466914339296

---

**How the Java Launcher Finds Classes**

The Java launcher, `java`, initiates the Java virtual machine. The virtual machine searches for and loads classes in this order:

- Bootstrap classes - Classes that comprise the Java platform, including the classes in `rt.jar` and several other important jar files.
- Extension classes - Classes that use the Java Extension mechanism. These are bundled as `.jar` files located in the extensions directory.
- User classes - Classes defined by developers and third parties that do not take advantage of the extension mechanism. You identify the location of these classes using the -classpath option on the command line (the preferred method) or by using the CLASSPATH environment variable. (See Setting the Classpath for [Windows or Unix](https://docs.oracle.com/javase/8/docs/technotes/tools/unix/classpath.html).)


原文: https://docs.oracle.com/javase/8/docs/technotes/tools/findingclasses.html
