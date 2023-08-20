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

## Introduction

Source Code: [gptbot](https://github.com/shwezhu/gptbot)



## Error Hanlding

Return and wrap error in low layer function (try to provide more context info), only handle errors and log info on the top of the function call stack. 

```go
func parseUsernamePassword(r *http.Request) (*map[string]string, error) {
	userInfo := make(map[string]string)
	if err := r.ParseForm(); err != nil {
    // wrap error which can provide more context info
    // usually, say: "failed to" + "function name" + "error"
    // but not always
		return nil, fmt.Errorf("falied to parse username and password: %v", err)
	}
  ...
}

func updateMessage(w http.ResponseWriter, r *http.Request, store *redistore.RediStore) error {
	session, err := store.Get(r, "session_id")
	if err != nil {
		return fmt.Errorf("cannot update message: %v", err)
	}
  ...
	if err = session.Save(r, w); err != nil {
		return fmt.Errorf("cannot update message: %v", err)
	}
  ...
}
```

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

## Session Store

sessions need a place to store, in-memory, file or Redis, package [gorilla/sessions](https://github.com/gorilla/sessions) provides two way to save sessions, one is file, another is in-memory, 

```go
var store = sessions.NewCookieStore([]byte(os.Getenv("SESSION_KEY")))
// or 
var store =  NewFilesytemStore("path/to/file", []byte(os.Getenv("SESSION_KEY")))
```

I choose redis to save sessions with [redistore](https://github.com/boj/redistore) library, which implements a redis store based on [gorilla/sessions](https://github.com/gorilla/sessions), 

```go
var store, _ = redistore.NewRediStore(10, "tcp", ":6379", "", []byte(os.Getenv("SESSION_KEY")))
```

You can use [gorilla/sessions](https://github.com/gorilla/sessions) which help you save session in-memory, if you want save sessions on a redis server too, you have to install Redis on your computer, learn more about session and Redis: 

- [Introduce Redis | 橘猫小八的鱼](https://davidzhu.xyz/2023/08/18/Database/Redis/001-intro-redis/)
- [Cookie & Session | 橘猫小八的鱼](https://davidzhu.xyz/2023/08/17/CS-Basics/005-session-cookie/)
- [Go 每日一库之 gorilla/sessions - 大俊的博客](https://darjun.github.io/2021/07/25/godailylib/gorilla/sessions/)
- [GoAuthentication/readme.md at master · karankumarshreds/GoAuthentication](https://github.com/karankumarshreds/GoAuthentication/blob/master/readme.md)
