---
title: MongoDB in Action Reading Note
date: 2024-01-08 17:38:35
categories:
 - database
tags:
 - database
 - mongodb
---

## Basic Theory

MongoDB stores its information in **documents** rather than **rows**. Where relational databases have **tables**, MongoDB has ***collections***. 

Every MongoDB document requires an _id, and if one isn’t present when the document is created, a special MongoDB ObjectID will be generated and added to the document at that time. You can set your own _id by setting it in the document you insert, the ObjectID is just MongoDB’s default.

“Indexes don’t come for free; they take up some space and can make your inserts slightly more expensive, but they are an essential tool for query optimization.”

> MongoDB 没有传统数据库中 join 和 foreign key 的的概念, 但是可以通过嵌套文档或 Reference 来表示一对多或多对多的关系, 也可使用聚合来实现类似 Join 的功能. Join 为了同时获得多个表的内容, foreign key 为了数据一致性(data consistency and integrity), [了解更多](https://chat.openai.com/share/419afe95-279b-477f-8afa-8f75ab76edad)
> 了解更多: [Basic MySQL - David's Blog](https://davidzhu.xyz/post/database/mysql/002-basic-sql/)

## Examples in the Book

### Reviews - One to Many Relationship

Each *product* can have many *reviews*, and you create this relationship by storing a `product_id` in each *review*, as shown in the sample document:

```json
{   
    _id: ObjectId("4c4b1476238d3b4dd5000041"),   
    product_id: ObjectId("4c4b1476238d3b4dd5003981"),   
    date: new Date(2010, 5, 7),   
    title: "Amazing",   
    text: "Has a squeaky wheel, but still a darn good wheelbarrow.",   
    rating: 4,   
    user_id: ObjectId("4c4b1476238d3b4dd5000042"),   
    username: "dgreenthumb",   
    helpful_votes: 3,   
    voter_ids: [
            ObjectId("4c4b1476238d3b4dd5000033"),     
            ObjectId("7a4f0376238d3b4dd5000003"),     
            ObjectId("92c21476238d3b4dd5000032")   
        ]
}
```

> “But it may come as a surprise that you store the username as well. If this were an RDBMS, you’d be able to pull in the username with a join on the users table. Because you don’t have the join option with MongoDB, you can proceed in one of two ways: either query against the user collection for each review or accept some **denormalization**. Issuing a query for every review might be unnecessarily costly when username is extremely unlikely to change, so here we’ve chosen to optimize for query speed rather than **normalization**.”
>
> “Also noteworthy is the decision to store votes in the review document itself. It’s common for users to be able to vote on reviews. Here, you store the object ID of each voting user in an array of voter IDs. This allows you to prevent users from voting on a review more than once, and it also gives you the ability to query for all the reviews a user has voted on. You **cache** the total number of helpful votes, which among other things allows you to sort reviews based on helpfulness. Caching is useful because **MongoDB doesn’t allow you to query the size of an array within a document**. A query to sort reviews by helpful votes, for example, is much easier if the size of the voting array is cached in the helpful_votes field.”

这段提到了一个关键概念：缓存（Caching）, 这里的 “缓存” 是指在文档中直接存储一个额外的数据项（在这个例子中是“有帮助的投票数”），而不是每次查询时计算这个数值。

在MongoDB中，直接通过简单查询来计算文档内数组的大小（即数组中元素的数量）并不直接支持, (你可以通过聚合框架计算数组大小, 但聚合查询通常比简单的文档查询更复杂且性能开销更大, 尤其是在处理大量数据时)

## Constructing queries - Action in MongoDB chapter 5

### Find & FindOne Functions
`find` returns a cursor object, whereas `findOne` returns a document. The findOne method is similar to the following, though a cursor is returned even when you apply a limit:

```js
mongoose.products.find({'slug': 'wheel-barrow-9092'}, null, null).limit(1)

mongoose.reviews.find({'product_id': product['_id']}, null, null)
    .sort({'helpful_votes': -1})
    .limit(12)

mongoose.users.find({'addresses.zip': {'$gt': 10019, '$lt': 10040}}, null, null)
```

> `null` is in the mongoose stryle, I use Nodejs, so this can help remind me of the another two parameters: `projection` and `options`.
> `db.collection.findOne(query, projection, options)`


### Projection parameter of find and findOne

> MongoDB store documents in a collection in no particular order. To get documents in a particular order, you must can use the `sort()` method or the `$sort` aggregation pipeline stage. 
> Learn more: [natural order — MongoDB Manual](https://www.mongodb.com/docs/manual/reference/glossary/#std-term-natural-order)

```js
mongoose.users.findOne(
    {“username': 'kbanker', 'hashed_password': 'bd1cfa194c3a603e7186780824b04419'},
    {'_id': 1},
    null,
)
```

If you are already familiar with SQL and RDBMS, this is the difference between `SELECT *` and `SELECT ID`. 

## Query Operators

前面介绍了find函数的基本用法和projection参数, 在实际查询中, 我们还需要使用一些操作符来构建更复杂的查询条件, 接下来一一介绍. 

Learn more: [Query and Projection Operators — MongoDB Manual](https://www.mongodb.com/docs/manual/reference/operator/query/)

### Set operators

`$in`, `$nin`, `$all`

```js
// $in: Matches any of the values specified in an array.
db.products.find({
    'main_cat_id': {
        '$in': [
            ObjectId("6a5b1476238d3b4dd5000048"),         
            ObjectId("6a5b1476238d3b4dd5000051"),         
            ObjectId("6a5b1476238d3b4dd5000057")       
        ]
    }
}, null, null)

// Query nested documents
db.products.find({'details.color': {$in: ['blue', 'Green']}})
```

### Boolean operators

`$or`, `$and`, `$not`, `$nor`, `$exists`

```js
// $or: matches if any of the supplied set of query terms is true
// Finding all products that are either blue or made by Acme requires:
db.products.find({
    '$or': [
        {'details.color': 'blue'},
        {'manufacturer': 'Acme'},
    ]
})
```

## Querying arrays

[Query an Array — MongoDB Manual](https://www.mongodb.com/docs/manual/tutorial/query-arrays/)



