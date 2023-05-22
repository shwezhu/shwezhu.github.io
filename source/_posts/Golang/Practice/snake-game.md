---
title: 用Go实现一个简单的贪吃蛇
date: 2023-05-20 19:59:9
categories:
 - Golang
 - Practice
tags:
 - Golang
 - Game
---

Go也学了几天了, 在学习泛型和并发之前打算实践一下, 熟悉一下语法, 不然一直理论没有实践是很容易学懵的, 实现思路如下: 

**地图**

地图就是个二维数组`board`, 在Go里面叫Slice of slices, 不清楚可以看这篇[Golang容器之Array & Slice & Map ](https://davidzhu.xyz/2023/05/13/Golang/Basics/collections/), 该地图(二维数组)存储bool类型, 定义如下和结构如下:

```go
// height = 4, width = 3
func main() {
  // Definition
	board := make([][]bool, height)
	for i := range board {
		board[i] = make([]bool, width)
	}
  // Test
	board[2][1] = true
	for y := range board{
		for _, v := range board[y] {
			fmt.Printf("%v ", v)
		}
		println()
	}
}

false false false 
false false false 
false true false 
false false false 
```

----

**打印蛇🐍身体**

蛇的身体由多个节点组成, 节点是个struct类型, 如下:

```go
type node struct {
	x int
	y int
}
```

把地图设计成存储布尔类型的数组的目的就是方便打印蛇的身体, 也是实现的关键, 即每次循环`board`(代表地图的二维数组), 遇到false就打印空白, 遇到true就打印一个黑色方块▪️代表蛇的身体:

```go
func draw() {
	fmt.Print("\033[H\033[2J")
	// original: 'for y, _ := range board { ... }'
	for y := range board {
		for x, xValue := range board[y] {
			if !xValue && (food.x != x || food.y != y) {
				fmt.Print("□ ")
			} else if !xValue && food.x == x && food.y == y {
				fmt.Print("★ ")
			} else {
				fmt.Print("■ ")
			}
		}
		fmt.Println()
	}
}
```

这样我们只需要写个函数根据蛇的身体(多个节点)来修改(更新)`board`里面每个元素的值, 然后再写个函数(也就是上面的`draw()`)根据`board`来画地图就好了, 注意画地图的时候也画了蛇的身体:

```go
func update() {
  // 这里访问二维数组的时候第一个是高度, 第二个是宽度
  // 即board[0][2]代表第1个数组的第3个元素, 所以我们写成 board[v.y][v.x] = true
  // 而不是board[v.x][v.y] = true
	for _, v := range snake{
		board[v.y][v.x] = true
	}
	// draw map and snake and food
	draw()
}
```

---

**让蛇动起来**

让蛇动起来的方法有多种, 在这里比如每次reset地图`board`的数据为false, 然后再根据蛇的身体`snake`更新`board`, 但这样效率稍低, 因为每次我们都需要遍历board去reset, 仔细想一下蛇每次移动, 其实就是最前面的头往前移动一格, 尾巴往前移动一格, 中间的身体**看着**是不变的, 所以我们在实现的时候也是有三步:

- 1 根据当前方向`direction`修改`snake`第一个元素的坐标, 实现蛇头前进一格

```go
  // change the head position
	switch direction {
	case right:
		snake[0].x++
	case left:
		snake[0].x--
	case up:
		snake[0].y--
	case down:
		snake[0].y++
	}
```

- 2 遍历`snake`, 使第`i`个元素的坐标等于第`i-1`个元素的坐标(`i>=1`),实现中间的身体看着是不动的, 其实每个节点都前进了

```go
length := len(snake)
// "move" all node of snake except the head
if length > 1 {
	// make the value of each (i)th element equal to the (i-1)th value
	for i := len(snake) - 1; i >= 1; i-- {
	snake[i] = snake[i-1]
	}
}
```

- 3 设置位置在蛇的最后一个节点即尾巴`(snake[len - 1].x, snake[len - 1].y)`的`board`元素为false, 因为在第2步尾巴已经变成倒数第二个元素的坐标了, 所以我们要把旧的尾巴坐标位置设置为false

即这样只遍历了`snake`(一维数组)来实现更新地图, 具体吃食物增加节点就不介绍了, 逻辑很容易, 

----

**总结**

这次的小应用, 熟悉了slice的用法, 也熟悉了很多语法比如`:=`和`var`, 尤其是遍历slice以及loop的写法, 比如无限循环可写成:

```go
for {
  ...
}
```

其次是导入第三方模块, 如这里读取键盘我们使用的是第三方库, 安装方法很简单, 即在项目根目录执行:

```shell
$ go get github.com/eiannone/keyboard
```

然后项目里就会多出`go.mod`和`mod.sum`文件, 里面保存了第三方库的版本, 有点像Java里的maven`pom.xml`, 或者是npm的`package.json`, 当然肯定是不一样的他们, 最近作业有点多, 还没仔细研究, 另外注意, 如果是在Goland上开发, 可能会报错`$GOPATH/go.mod exists but should not exist`, 这个原因是你项目设置了`Project GOPATH`, 在Goland设置里删除就好了, 以上这些和包相关的问题可以参考这篇文章 [Golang模块module和包package的使用之导入自定义包](https://davidzhu.xyz/2023/05/21/Golang/Basics/go-modules/)

最后是关于线程, goroutine, 这个改天再研究, 研究了一下怎么关闭线程, 可以参考:[Golang Goroutine和Select](https://davidzhu.xyz/2023/05/21/Golang/Basics/goroutines-select/)

源码如下:

```go
package main

import (
	"fmt"
	"github.com/eiannone/keyboard"
	"math/rand"
	"time"
)

const (
	width = 20
	height = 20
)

const (
	right = 0
	left  = 1
	up    = 2
	down  = 3
)

type node struct {
	x int
	y int
}

var (
	board 		= make([][]bool, height)
	snake 		= []node{{x: width / 2, y: height / 2}, {x: width / 2 + 1, y: height / 2}}
	food        = node{1, 3}
	direction   = left
	refreshRate = time.Millisecond * 300
	gameOver    = false
)

func generateFood() {
	food.x = rand.Intn(width)
	food.y = rand.Intn(height)
}

func draw() {
	fmt.Print("\033[H\033[2J")
	// original: 'for y, _ := range board { ... }'
	for y := range board {
		for x, xValue := range board[y] {
			if !xValue && (food.x != x || food.y != y) {
				fmt.Print("□ ")
			} else if !xValue && food.x == x && food.y == y {
				fmt.Print("★ ")
			} else {
				fmt.Print("■ ")
			}
		}
		fmt.Println()
	}
}

func update() {
	for _, v := range snake{
		board[v.y][v.x] = true
	}

	// draw map and snake and food
	draw()

	// decide if snake hit the wall
	x := snake[0].x
	y := snake[0].y
	if x >= width - 1 || x <= 0 || y >= height - 1 || y <= 0 {
		gameOver = true
	}

	// let snake move, change the position of snake for next calling of draw()
	// by changing the x,y value of snake[0] and snake[len(snake)-1] to make snake "move"
	length := len(snake)
	// ate food, increase length
	if snake[0] == food {
		snake = append(snake, node{})
		generateFood()
	} else {
		// clean the tail on map
		board[snake[length - 1].y][snake[length - 1].x] = false
	}
	// "move" all node of snake except the head
	if length > 1 {
		// Make the value of each (i)th element equal to the (i-1)th value
		for i := len(snake) - 1; i >= 1; i-- {
			snake[i] = snake[i-1]
		}
	}

	// change the head position
	switch direction {
	case right:
		snake[0].x++
	case left:
		snake[0].x--
	case up:
		snake[0].y--
	case down:
		snake[0].y++
	}
}

func handleInput(quit chan bool) {
	for {
		select {
		case <- quit:
			close(quit)
			return
		default:
      // 每次退出游戏后 需要再按一次按键才能退出就是因为这个GetKey
      // 你按下q之后, gameOver确实被改成了true
      // 且在main中执行到了quit <- true
      // 但handleInput是个无限循环, 在‘quit <- true’和main的无限循环退出之间
      // handleInput又开始了下一次循环, 即此时quit还没被写入数据, 所以跳到了下面这段代码
      // keyboard.GetSingleKey(), 所以程序卡住了, 你需要多按一次按键才能游戏结束, 
      // 还没想到合适的办法解决
			char, _, err := keyboard.GetSingleKey()
			if err != nil {
				panic(err)
			}

			switch char {
			case 'w', 'W':
				if direction != down {
					direction = up
				}
			case 'a', 'A':
				if direction != right {
					direction = left
				}
			case 's', 'S':
				if direction != up {
					direction = down
				}
			case 'd', 'D':
				if direction != left {
					direction = right
				}
			case 'q', 'Q':
				gameOver = true
			}
		}
	}
}

// init() function will be called once automatically.
func init() {
	// original: 'for i, _ := range board { ... }'
	for i := range board {
		board[i] = make([]bool, width)
	}
}

func main() {
	if err := keyboard.Open(); err != nil {
		panic(err)
	}
	// call anonymous function, often used in these sensorial: defer、go
	defer func() {
		err := keyboard.Close()
		if err != nil {
			return
		}
	}()

	quit := make(chan bool)
	go handleInput(quit)

	for !gameOver {
		update()
		time.Sleep(refreshRate)
	}
	
	quit <- true
	fmt.Printf("Game Over!\n")
}
```

