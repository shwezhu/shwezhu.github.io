---
title: MongoDB in Action Reading Note
date: 2024-01-08 17:38:35
categories:
 - database
tags:
 - database
 - mongodb
---

MongoDB stores its information in **documents** rather than **rows**. Where relational databases have **tables**, MongoDB has ***collections***. 

Every MongoDB document requires an _id, and if one isn’t present when the document is created, a special MongoDB ObjectID will be generated and added to the document at that time. You can set your own _id by setting it in the document you insert, the ObjectID is just MongoDB’s default.

“Indexes don’t come for free; they take up some space and can make your inserts slightly more expensive, but they are an essential tool for query optimization.”

> MongoDB 没有 join 和 foreign key 的的概念, 但是可以通过嵌套文档来实现类似 Join 的功能, 以及使用 Reference 来实现类似 Foreign Key 的功能. 前者为了查询, 后者为了数据一致性, [了解更多](https://chat.openai.com/share/419afe95-279b-477f-8afa-8f75ab76edad)
