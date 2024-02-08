---
title: MongoDB Docs
date: 2024-01-08 08:38:35
categories:
 - database
tags:
 - database
 - mongodb
---

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



