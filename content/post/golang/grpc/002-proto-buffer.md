---
title: Ptotocol Buffers
date: 2024-01-19 00:01:08
categories:
 - grpc
tags:
 - grpc
---

## Quick start

Execute the following commands at your terminal, you don't need to execute them under your project folder, just execute them anywhere, it will install the `protoc` compiler and the `protoc-gen-go` and `protoc-gen-go-grpc` plugins into your `$GOPATH/bin` folder.

```shell
# install protoc compiler
$ brew install protobuf
$ protoc --version  # Ensure compiler version is 3+

# install plugins to $GOPATH/bin
$ go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
$ go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

> Update your PATH so that the protoc compiler can find the plugins: `export PATH="$PATH:$(go env GOPATH)/bin"`

## protoc command

### Install

```shell
$ brew install protobuf
$ protoc --version
```

### Usage

```shell
❯ protoc --help
Usage: protoc [OPTION] PROTO_FILES

  -IPATH, --proto_path=PATH   指定搜索路径
  --plugin=EXECUTABLE:
  
  ....
 
  --cpp_out=OUT_DIR           Generate C++ header and source.
  --csharp_out=OUT_DIR        Generate C# source file.
  --java_out=OUT_DIR          Generate Java source file.
  --js_out=OUT_DIR            Generate JavaScript source.
  --objc_out=OUT_DIR          Generate Objective C header and source.
  --php_out=OUT_DIR           Generate PHP source file.
  --python_out=OUT_DIR        Generate Python source file.
  --ruby_out=OUT_DIR          Generate Ruby source file
```

- `PROTO_FILES`：the proto files goin to be compiled

**搜索路径参数**
- `-IPATH`, `--proto_path=PATH`: 指定查找 `.proto` 文件的目录, 比如 `.proto` 中有 import，编译器会在这个目录下搜索被引用的 `.proto` 文件
  - 如: `-I.` 表示在当前目录下搜索
  - 如果不指定该参数，则默认在当前路径下进行搜索

**语言插件参数**

语言参数即上述的--cpp_out=，--python_out=等, 列出的语言表示 protoc 本身已经内置该语言对应的编译插件, 无需安装. Dart, Go 由google维护，通过protoc的插件机制来实现，所以仓库单独维护. 

**语言插件**

非内置的语言支持就得自己单独安装语言插件, 安装命令如下：

```shell
$ go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
```

之前[介绍了 `go install`](https://davidzhu.xyz/post/golang/basics/000-modules-env/), 将会把 `protoc-gen-go` 安装到 `$GOPATH/bin` 目录下, 之后就可以在 `protoc` 命令中使用 `--go_out` 等参数了. 

> 注意: protoc-gen-go 要求 pb (`.proto`) 文件中必须指定 go 包的路径, 例如，`option go_package = "github.com/shwezhu/consignment-service/proto/consignment"`. 
> 文件结构: `consignment-service/proto/consignment/consignment.proto` 

### protoc-gen-go 插件

注意按照上面安装了 `protoc-gen-go` 插件后, 你便可以通过 `protoc` 命令来指定 `--go_out`, `--go_opt` 参数了, 这两个参数是 `protoc-gen-go` 插件的参数, 而不是 `protoc` 的参数.

下面详细介绍一下:

- `--go_out`: 指定go代码生成的基本路径
- `--go_opt`: 设定插件参数, 一般有两个值: `paths=source_relative` 和 `import`
  - `paths=source_relative`: 生成的go文件的包路径将会是相对于 `.proto` 文件的源目录
    - 例如你的 `.proto` 文件位于 `proto/myapp/myproto.proto`, 若使用 `paths=source_relative` 选项，生成的 Go 文件将会在类似 `myapp/myproto.pb.go` 的路径下
  - `paths=import`: 生成的go文件的包路径将基于 `.proto` 文件中指定的 `go_package`
  - 例如你在 `myproto.proto` 文件中指定了 `option go_package = "github.com/example/project/proto";`，那么无论 `.proto` 文件的实际位置在哪里，生成的 Go 文件都将使用这个路径作为包路径。

```shell
$ protoc I. --go_out=. --go_opt=paths=source_relative \
    --go-grpc_out=. --go-grpc_opt=paths=source_relative \
    chat.proto

# or
$ protoc I. --go_out=. --go_opt=paths=import \
    --go-grpc_out=. --go-grpc_opt=paths=import \
    chat.proto
```

> 第四个参数 `--go-grpc_out` 不是 `protoc-gen-go` 插件 的参数, 而是 grpc go 插件, 下面会讲, 现在只用关注 `--go_out`, `--go_opt` 两个参数. 

### grpc go 插件

在 google.golang.org/protobuf 中, `protoc-gen-go` 纯粹用来生成pb(`.proto`)序列化相关的文件, 不再承载 gRPC 代码生成功能, 生成gRPC相关代码需要安装 grpc-go 相关的插件 `protoc-gen-go-grpc`, 安装命令如下:

```shell
 $ go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

插件 `protoc-gen-go-grpc` 也有两个参数, 类似 `protoc-gen-go` 插件的 `--go_out`, `--go_opt` 参数, 分别是 `--go-grpc_out`, `--go-grpc_opt`, 用法也是一样的,

### 综合示例

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
