---
title: MongoDB Docs
date: 2024-01-08 08:38:35
categories:
 - database
tags:
 - database
 - mongodb
---

## 1. Query documents

[MongoDB does not store documents in a collection in a particular order](https://arc.net/l/quote/shtunvlw). To get documents in a particular order, you must can use the `sort()` method or the `$sort` aggregation pipeline stage.

The MongoDB Compass **Find** operation opens a [cursor](https://www.mongodb.com/docs/manual/tutorial/iterate-a-cursor/) to the matching documents of the collection based on the find query.

Modify the Cursor Behavior: mongosh and the [drivers](https://www.mongodb.com/docs/drivers/) provide several cursor methods that call on the *cursor* returned by the [`find()`](https://www.mongodb.com/docs/manual/reference/method/db.collection.find/#mongodb-method-db.collection.find) method to modify its behavior. 

```js
db.bios.find().sort( { name: 1 } )
db.bios.find().limit( 5 )
// skips the first 5 documents
db.bios.find().skip( 5 )
// chain
db.bios.find().sort( { name: 1 } ).limit( 5 )
db.bios.find().limit( 5 ).sort( { name: 1 } )
```

Learn more: [db.collection.find() — MongoDB Manual](https://www.mongodb.com/docs/manual/reference/method/db.collection.find/#available-mongosh-cursor-methods)
