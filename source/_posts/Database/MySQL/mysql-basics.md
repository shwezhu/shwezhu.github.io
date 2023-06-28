---
title: MySQL 基础
date: 2023-06-27 16:41:35
categories:
 - Database
tags:
 - Database
---
## Naming Conventions

**General**

1. Using lowercase will help speed typing, avoid mistakes as MYSQL is case sensitive. 

2. Space replaced with Underscore — Using space between words is not advised.

3. Numbers are not for names — While naming, it is essential that it contains only Alpha English alphabets.

**Table**

1. Table names are lower case, uses underscores to separate words, and are singular (e.g. `foo`, `foo_bar`, etc.

**Columns**

1. Always use the **singular name.**
2. Always use **lowercase** except where it may make sense not to such as proper nouns.
3. Where possible **avoid simply using `id`** as the primary identifier for the table.
4. Do not add a column with the same name as its table and vice versa.
5. I generally (not always) have a auto increment PK. I use the following convention: `tablename_id` (e.g. `foo_id`, `foo_bar_id`, etc.).

## 基础命令

登录 MySQL 服务器:

```shell
$ mysql -u root -p778899
mysql> show databases;
mysql> create database gptbot;
mysql> use gptbot;
```

创建表:

```shell
CREATE TABLE `user` (
  `user_id` SMALLINT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(20) NOT NULL,
  `password` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`user_id`)
);
```

## 数据类型





参考:

- [MYSQL Naming Conventions. What is MYSQL? | by Centizen Nationwide | Medium](https://medium.com/@centizennationwide/mysql-naming-conventions-e3a6f6219efe)
- [Is there a naming convention for MySQL? - Stack Overflow](https://stackoverflow.com/questions/7899200/is-there-a-naming-convention-for-mysql)
- [SQL style guide by Simon Holywell](https://www.sqlstyle.guide/#columns)