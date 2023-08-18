---
title: Golang Web - A Simple GPTBot with Openai API
date: 2023-08-18 09:20:57
categories:
 - Golang
 - Practice
tags:
 - Golang
 - Practice
---



## Session or Redis Cache





I did some experiments , found that a query with gorm for sqlite3 takes about 380us, it's not that much, and there will no that many users can overwhelm my server, so I finally decide query the `tokens` value from database everytime when user make a request to chat with ChatGPT, 

```go
// https://stackoverflow.com/a/45791377/16317008
start := time.Now()
err = db.Limit(1).Find(&user, "username = ?", (*userInfo)["username"]).Error
t := time.Now()
fmt.Println(t.Sub(start))
--------------------------------
1.514166ms // first time
542.125µs
387.625µs
484.958µs
477.417µs
377.959µs
..
```

