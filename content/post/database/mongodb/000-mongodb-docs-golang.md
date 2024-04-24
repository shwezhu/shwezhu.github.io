---
title: MongoDB Docs - Golang
date: 2024-04-23 08:38:35
categories:
 - database
tags:
 - database
 - mongodb
---

## Bson & Marshalling & Unmarshalling

The process of converting a Go type to BSON is called **marshalling**, while the reverse process is called **unmarshalling**.

**Why need convert Go type to BSON?** MongoDB stores documents in [BSON](https://www.mongodb.com/docs/manual/reference/bson-types/), when we store data (our struct) into MongoDB,  MongoDB Go-driver convert our struct value into bson automatically.

The Go driver provides four main types for working with BSON data:

- `D`: An ordered representation of a BSON document (slice)
- `M`: An unordered representation of a BSON document (map)
- ...

D is an ordered representation of a BSON document. This type should be used when the order of the elements matters, such as MongoDB command documents. If the order of the elements does not matter, an M should be used instead. This usually used as filter in a query operation. 

Like what we said before, our Go struct value needs to be converted to bson, there are **Struct Tags**, which is used to modify the default marshalling and unmarshalling behavior of a struct field. 

After we read data from MongoDB, we need to convert bson to Go struct, this is called **unmarshalling**. You can unmarshal BSON documents by using the `Decode()` method on the result of the `FindOne` method or any `*mongo.Cursor` instance. 

> Note that when using `FindOne()` it returns a bson document, so you need decode it back to a Go struct value. 
>
> Method `Find()` returns a `*mongo.Cursor`, we usually iterate through it so get more than one (probably) result. And `*mongo.Cursor` needs to be closed usually to free resources. 

Learn more: 

[mongodb - bson.D vs bson.M for find queries - Stack Overflow](https://stackoverflow.com/questions/64281675/bson-d-vs-bson-m-for-find-queries)

[Work with BSON - Go Driver v1.15](https://www.mongodb.com/docs/drivers/go/current/fundamentals/bson/)

## Read Operation

To match a subset of documents, specify a **query filter**. In a query filter, you can match fields with [literal values](https://www.mongodb.com/docs/drivers/go/current/fundamentals/crud/read-operations/query-document/#std-label-golang-literal-values) or with [query operators](https://www.mongodb.com/docs/drivers/go/current/fundamentals/crud/read-operations/query-document/#std-label-golang-query-operators).

### `*mongo.Cursor`

A cursor is used to iterate over database results from read operations. **A cursor is not goroutine safe**. Do not use the same cursor in multiple goroutines at the same time. Method `Find()` returns a cursor. 

You can retrieve results individually or get all results at a time, it depends on if the number of the result is very large. 

```go
cursor, _ := coll.Find(context.TODO(), bson.D{})

// retrieve results individually
for cursor.Next(context.TODO()) {
	var result MyStruct
	if err := cursor.Decode(&result); err != nil {
		log.Fatal(err)
	}
	fmt.Printf("%+v\n", result)
}

// get all results at a time
var results []MyStruct
if err = cursor.All(context.TODO(), &results); err != nil {
	panic(err)
}
```

If the number and size of documents returned by your query exceeds available application memory, your program will crash. If you except a large result set, you should [consume your cursor iteratively.](https://www.mongodb.com/docs/drivers/go/current/fundamentals/crud/read-operations/cursor/#std-label-golang-individual-documents)

> When your application no longer requires a cursor, close the cursor with the `Close()` method. This method frees the resources your cursor consumes in both the client application and the MongoDB server.  Close the cursor when you [retrieve documents individually](https://www.mongodb.com/docs/drivers/go/current/fundamentals/crud/read-operations/cursor/#std-label-golang-individual-documents) because those methods make a cursor [tailable.](https://www.mongodb.com/docs/manual/core/tailable-cursors/)









If the necessary database and collection don't exist when you perform a write operation, the server implicitly creates them.

`bson:"sizes,truncate"`
bson: binary json
modify behvavior when query: opts third parameter
cursor: when to close the cursor
collection: use concurrentlly

```js
// return the old document, with {new: true} return the updated document.
Model.findByIdAndUpdate()
```


## Query

```json
{
  "address": {
     "building": "1007",
     "coord": [ -73.856077, 40.848447 ],
     "street": "Morris Park Ave",
     "zipcode": "10462"
  },
  "borough": "Bronx",
  "cuisine": "Bakery",
  "grades": [
     { "date": { "$date": 1393804800000 }, "grade": "A", "score": 2 },
     { "date": { "$date": 1378857600000 }, "grade": "A", "score": 6 },
     { "date": { "$date": 1358985600000 }, "grade": "A", "score": 10 },
     { "date": { "$date": 1322006400000 }, "grade": "A", "score": 9 },
     { "date": { "$date": 1299715200000 }, "grade": "B", "score": 14 }
  ],
  "name": "Morris Park Bake Shop",
  "restaurant_id": "30075445"
}
```

### db.collection.find(query, projection, options)

```js
db.restaurants.find({}, {_id: 1, name:1})
db.restaurants.find({"borough": "Bronx"}).limit(5);
db.restaurants.find({"borough": "Bronx"}).skip(5).limit(5);
```

`$elemMatch` 用于在**数组类型的字段**中选择元素, 需要**数组至少有一个元素符合多个查询条件时**, `$elemMatch` 尤其有用:

```js
// the restaurants that achieved a score, more than 80 but less than 90
db.restaurants.find({grades: {$elemMatch: {score: {$gt: 80, $lt:90}} }})
```



## Reference

[Work with BSON - Go Driver v1.15](https://www.mongodb.com/docs/drivers/go/current/fundamentals/bson/)
