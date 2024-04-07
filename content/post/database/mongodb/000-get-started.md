---
title: MongoDB Get Started
date: 2024-03-30 19:27:35
categories:
 - database
tags:
 - database
 - mongodb
---

## Install MongoDB

[Install MongoDB Community Edition on macOS — MongoDB Manual](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-os-x/)

## Start MongoDB

```sh
brew services start mongodb-community
```

## MongoDB Shell

```sh
❯ mongosh
```

## Common Commands

```sh
// 创建或者切换数据库
use myDatabase

// 显示当前数据库
db

// 显示所有数据库
show dbs

// 显示当前数据库中的集合
show collections

// 向集合中插入单个文档
db.collection.insertOne({ name: "Alice", age: 25 })

// 查询集合中的所有文档
db.collection.find()

// 删除集合
db.collection.drop()

// 退出MongoDB shell
quit()
```