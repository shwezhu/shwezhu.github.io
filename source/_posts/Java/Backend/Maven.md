---
title: Maven安装与使用以及查看Maven项目的ClassPath
date: 2023-04-25 14:11:30
categories:
 - Java
 - Backend
tags:
 - Java
 - Maven
---

# Artifact & Group
创建好maven项目后, 在项目根目录下有个`pom.xml`文件, 这个就是maven的配置文件, 你可以在里面添加各种依赖, 比如想用mysql driver, gson, log4j等第三方库的时候, 直接在dependencies标签下添加:

```xml
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.32</version>
</dependency>
```

那么问题来了, 上面dependence标签下的artifactId和groupId是什么呢? 仔细观察`pom.xml`内容你会发现, 在其开头也会有我们的项目相关的信息, 也是这些奇怪的标签:

```xml
<groupId>com.example</groupId>
<artifactId>ServletDemo</artifactId>
<version>1.0-SNAPSHOT</version>
<name>ServletDemo</name>
<packaging>war</packaging>
```

其中，`groupId`类似于Java的包名，通常是公司或组织名称，`artifactId`类似于Java的类名，通常是项目名称，再加上`version`，一个Maven工程就是由`groupId`，`artifactId`和`version`作为唯一标识。

在Maven项目中，类的`classpath`路径是由Maven依赖管理机制决定的。Maven通过`pom.xml`管理项目依赖，当我们使用`<dependency>`声明一个依赖后，Maven会根据`pom.xml`文件中的配置将依赖下载到本地仓库，然后将其添加到项目的`classpath`中。

## 查看classpath

Mac, Linux查看当前maven项目的classpath, 注意要在项目的根目录下输入此命令, 不然会提示错误找不到`pom.xml`文件, 
```shell
mvn -q exec:exec -Dexec.executable=echo -Dexec.args="%classpath"
/Users/shaowen/Codes/IDEA/ServletDemo/target/classes:/Users/shaowen/.m2/repository/com/mysql/mysql-connector-j/8.0.32/mysql-connector-j-8.0.32.jar:/Users/shaowen/.m2/repository/log4j/log4j/1.2.17/log4j-1.2.17.jar
```

可以看到, classpath路径的第一个是`/Users/shaowen/Codes/IDEA/ServletDemo/target/classes/`, 这个文件夹下面就是我们project/src/main/java/下的类, 编译成的class文件 都放这下面了. 所以项目就是这么找到我们编写的类的, 

了解更多关于输出classpath: https://stackoverflow.com/a/45043803/16317008

# Install Maven

**1.Go to Maven [Download site]( https://maven.apache.org/download.cgi)**

![](a.png)

**2.Set Environment Variables**

```shell
tar -xvf apache-maven-3.6.3-bin.tar.gz

export M2_HOME="/Users/shaowen/Downloads/Programs/apache-maven-3.9.1"
PATH="${M2_HOME}/bin:${PATH}"
export PATH

source .bash_profile
mvn -version
```
