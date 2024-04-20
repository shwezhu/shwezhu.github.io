---
title: Ptotocol Buffers
date: 2024-01-19 00:01:08
categories:
 - grpc
tags:
 - grpc
---

## 1. Quick start

Execute the following commands at your terminal, you don't need to execute them under your project folder, just execute them anywhere, it will install the `protoc` compiler and the `protoc-gen-go` and `protoc-gen-go-grpc` plugins into your `$GOPATH/bin` folder.

```shell
# install protoc compiler
$ brew install protobuf
$ protoc --version  # Ensure compiler version is 3+

# install plugins for 
$ go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
$ go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

> Update your `$PATH` so that the protoc compiler can find the plugins: `export PATH="$PATH:$(go env GOPATH)/bin"`

## 2. Usage

`protoc` 命令的基本用法是 `protoc [OPTION] PROTO_FILES`, 其中 `OPTION` 包括搜索路径参数, 语言插件参数等, `PROTO_FILES` 是要编译的 `.proto` 文件. 可以通过 `protoc --help` 查看所有参数. 下面主要介绍 `[OPTION]` 参数.

### 2.1. 搜索路径参数
- `-IPATH`, `--proto_path=PATH`: 指定搜索 `.proto` 文件的目录
  - 如: `-I.` 表示在当前目录下搜索
  - 如果不指定该参数，则默认在当前路径下进行搜索

### 2.2. 语言插件 `protoc-gen-go`

protoc 本身支持多种语言, --cpp_out=，--python_out=等, 但不支持 Go 由google维护，需要安装 protoc 插件：

```shell
$ go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
```

[之前介绍了 `go install`](https://davidzhu.xyz/post/golang/basics/000-modules-env/)会把 `protoc-gen-go` 安装到 `$GOPATH/bin` 目录下, 之后就可以在 `protoc` 命令中使用 `--go_out` 等参数了. 

> 注意: protoc-gen-go 要求 pb (`.proto`) 文件中必须指定 go 包的路径, 例如 `option go_package = "github.com/shwezhu/consignment-service/proto/consignment"`. 
> 文件结构: `consignment-service/proto/consignment/consignment.proto` 

```shell
$ protoc I. --go_out=. --go_opt=paths=source_relative \
    --go-grpc_out=. --go-grpc_opt=paths=source_relative \
    chat.proto

# or
$ protoc I. --go_out=. --go_opt=paths=import \
    --go-grpc_out=. --go-grpc_opt=paths=import \
    chat.proto
```

解释:

- `--go_out=.`
  - 作用: 指定go代码生成的基本路径
  - 属于哪个插件：这个参数是为 protoc-gen-go 插件设置的
- `--go_opt=paths=source_relative`
  - 属于哪个插件：这同样是为 protoc-gen-go 插件设置的
  - 一般有两个值: `paths=source_relative` 和 `paths=import`
  - `paths=source_relative`: 例如你的 `.proto` 文件位于 `proto/myapp/myproto.proto`, 若使用 `paths=source_relative` 选项，生成的 Go 文件将会在类似 `myapp/myproto.pb.go` 的路径下
  - `paths=import`: 例如你在 `myproto.proto` 文件中指定了 `option go_package = "github.com/example/project/proto";`，那么无论 `.proto` 文件的实际位置在哪里，生成的 Go 文件都将使用这个路径作为包路径
- `--go-grpc_out=.`
  - 属于哪个插件：这个参数是为 protoc-gen-go-grpc 插件设置的
- - `--go-grpc_opt=paths=source_relative`
  - 属于哪个插件：这是为 protoc-gen-go-grpc 插件设置的

> `protoc-gen-go` vs `protoc-gen-go-grpc`: The old-way is using `protoc-gen-go` that generates both serialization of the protobuf messages and grpc code. Now `protoc-gen-go` no longer supports generating gRPC service definitions. For gRPC code, a new plugin called `protoc-gen-go-grpc` was developed by Go gRPC project. [source](https://stackoverflow.com/a/64849053/16317008)

### 2.3. grpc go 插件

`protoc-gen-go` 纯粹用来生成pb(`.proto`)序列化相关的文件, 不再承载 gRPC 代码生成功能, 生成gRPC相关代码需要安装 grpc-go 相关的插件 `protoc-gen-go-grpc`, 安装命令如下:

```shell
$ go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

插件 `protoc-gen-go-grpc` 也有两个参数, 类似 `protoc-gen-go` 插件的 `--go_out`, `--go_opt` 参数, 分别是 `--go-grpc_out`, `--go-grpc_opt`, 用法也是一样的,

## 3. 综合示例

**项目结构:**

```shell
~/Codes/GoLand/shippy main*
❯ tree -L 4
.
├── README.md
└── consignment-service
    ├── Makefile
    └── proto
        └── consignment
            ├── consignment.proto
```

**`consignment.proto`**

```protobuf
syntax = "proto3";

// When compile for Go code, need this, the path under the project, no project folder name
option go_package = "github.com/shwezhu/consignment-service/proto/consignment";

// same as Go, it's the parent folder of this file.
package consignment;

service ShippingService {
  rpc CreateConsignment(Consignment) returns (Response) {}
}

...

```

**Makefile**

```makefile
build:
	protoc --go_out=. --go_opt=paths=source_relative \
	  	   --go-grpc_out=. --go-grpc_opt=paths=source_relative \
	  	   proto/consignment/consignment.proto
```

**执行命令**

```shell
~/Codes/GoLand/shippy/consignment-service main*
❯ make build
protoc --go_out=. --go_opt=paths=source_relative \
	  	   --go-grpc_out=. --go-grpc_opt=paths=source_relative \
	  	   proto/consignment/consignment.proto
```

**项目结构:**

执行上面的命令后, 文件结构如下:

```shell
~/Codes/GoLand/shippy main*
❯ tree -L 4
.
├── README.md
└── consignment-service
    ├── Makefile
    └── proto
        └── consignment
            ├── consignment.pb.go
            ├── consignment.proto
            └── consignment_grpc.pb.go
```


- `consignment.pb.go`: protoc-gen-go 插件的产出物, 包含所有类型的序列化和反序列化代码
- `consignment_grpc.pb.go`, protoc-gen-go-grpc 插件的产出物, 包含:
  - 定义在 `ShippingService` 中用来给client调用的接口定义
  - 定义在 `ShippingService` 中用来给服务端实现的接口定义

参考: [写给go开发者的gRPC教程-protobuf基础 - 掘金](https://juejin.cn/post/7191008929986379836)
