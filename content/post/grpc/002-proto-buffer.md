---
title: Ptotocol Buffers
date: 2023-11-05 20:01:08
categories:
 - grpc
tags:
 - grpc
---

## 1. Basics

Project structure:

```
.
├── client
│   └── main.go
├── go.mod
├── proto
│   └── chat
│       └──chat.proto
└── server
    └── main.go
```

```protobuf
syntax = "proto3";

// When compile for Go code, need this, the path under the project, no project folder name
option go_package = "proto/chat";

// same as Go, it's the parent folder of this file.
package chat;

message Message {
  string body = 1;
}

service ChatService {
  rpc SayHello(Message) returns (Message) {}
}
```

Compile to generate Go code:

```shell
$ protoc --go_out=. --go_opt=paths=source_relative \
    --go-grpc_out=. --go-grpc_opt=paths=source_relative \
    chat.proto
```

Project structure:

```
.
├── client
│   └── main.go
├── go.mod
├── proto
│   └── chat
│       ├── chat.pb.go
│       ├── chat.proto
│       └── chat_grpc.pb.go
└── server
    └── main.go
```

Learn more: [Go Protobuf Tips](https://jbrandhorst.com/post/go-protobuf-tips/)

## 2. 
