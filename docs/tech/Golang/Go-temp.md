# GO

数据类型 控制流程 

函数和异常


## 语言特性
1.天然并发 协程

```go
func main() {
    go fmt.Println(“hello")
}
```

2.管道 channel

多个goroute之间通过channel进行通信

```go
func main() {
  pipe := make(chan int,3)
  pipe <- 1
  pipe <- 2
}

```

## GO基本类型和操作符

GO里面好像没有类的概念。包+方法就可以了

## GO程序的基本结构

1.任何一个代码文件隶属于一个包

2.import 关键字，引用其他包

```go
import(“fmt”)
import(“os”)
```
通常写成：
```go
import (
      “fmt”
       “os”
)
```

3.golang可执行程序，package main，并且有且只有一个main入口函数

4.包中函数的调用，同一个包下的函数，可以直接调用，
不同包下的函数，通过“包名+点+函数名”进行调用

5.访问的权限控制：

```
大写意味着这个函数/变量是可导出的
小写意味着这个函数/变量是私有的，
     包外部不能访问
```

go的for不用写括号，例子：

```go
func list(n int) {
	for i := 0; i <= n; i++ {
		fmt.Printf("%d+%d=%d\n", i, n - i, n)
	}
}
```
## 包
别名

```go
import(
	a "go_dev/day2/example2/add"
	"fmt"
)


func main() {
	
	fmt.Println("Name=", a.Name)
	fmt.Println("age=", a.Age)
}
```
如果导入一个包，没有使用 只是用来初始化，那么可以这么写

```go
import(
	 _ "go_dev/day2/example2/test"
)
```
不同包的初始化函数执行的顺序，最底层的最先执行，就当前demo而言，先执行test 然后 add 最后main

## 常量

常量使用const 修饰，代表永远是只读的，不能修改

const 只能修饰boolean，number（int相关类型、浮点类型、complex）和string

语法：const identifier [type] = value，其中type可以省略

举例：

```go
const b String = "hello world"
const b = "hello world"

```

## 变量

语法：var identifier type

```go
var a String = "hello world"
```
iota 当前变量赋值为0 后面的变量自动加一
## 函数

函数声明： func   函数名字 (参数列表) (返回值列表）{}

```go
func add() {
} 

func add(a int , b int) (int, int) {
} 


```

## 值类型和引用类型

值类型：变量直接存储值，内存通常在栈中分配

引用类型：变量存储的是一个地址，这个地址存储最终的值。内存通常在堆上分配。通过GC回收。

值类型：基本数据类型int、float、bool、string以及数组和struct

引用类型：指针、slice、map、chan、interface等都是引用类型。

//值类型:变量直接存储值，内存通常在栈中分配
//引用类型:变量存储的是一个地址，这个地址对应的空间才真正存储数据(值)，
//内存通常在堆上分配，当没有任何变量引用这个地址时，该地址对应的数据空间就成为一个垃圾，由 GC 来回收
## 变量的作用域

在函数内部声明的变量叫做局部变量，生命周期仅限于函数内部

在函数外部声明的变量叫做全局变量，生命周期作用于整个包，如果是大写的，
则作用于整个程序

## 数据类型和操作符

数字类型主要有int、int8、int16、int32、int64、uint8、uint16、uint32、uint64、float32、float64

类型转换，type(variable），比如：var a int=8;  var b int32=int32(a)

```go
package main
func main() {
    var a int
    var b int32
    a = 15
    b = a + a // compiler error
    b = b + 5 // ok: 5 is a constant
} 

```


字符型
```go
var a byte = 'c'
```

字符串

```go
var str string = "hello"
```
字符串有两种表现形式 1）双引号    2）``   （反引号）会保持格式
	// 3.1 双引号, 会识别转义字符
	// 3.2 反引号，以字符串的原生形式输出，包括换行和特殊字符，可以实现防止攻击、输出源代码等效果

```go
package main
import “fmt”
func main() {
     var str = “hello world\n\n”     var str2 = `hello \n \n \n
                this is a test string
                This is a test string too·`
     fmt.Println(“str=“, str)
     fmt.Println(“str2=“, str2)
} 
```

## 字符串的操作/Strings和strconv的使用

1.go同java一样 也有占位符的API
2.切片

```go
func main() {
	var str1 = "hello"
	str2 := "world"
	
	str3 := fmt.Sprintf("%s %s", str1, str2)
	n := len(str3)

	fmt.Println(str3)

	fmt.Printf("len(str3)=%d\n", n)

	substr := str3[0:5]
	fmt.Println(substr)

	substr = str3[6:]
	fmt.Println(substr)
}
```

strings.HasPrefix(s string, prefix string) bool：判断字符串s是否以prefix开头 。

strings.HasSuffix(s string, suffix string) bool：判断字符串s是否以suffix结尾。

strings.Index(s string, str string) int：判断str在s中首次出现的位置，如果没有出现，则返回-1

strings.LastIndex(s string, str string) int：判断str在s中最后出现的位置，如果没有,
出现，则返回-1

strings.Itoa(i int)：把一个整数i转成字符串

strings.Atoi(str string)(int, error)：把一个字符串转成整数



## 时间和日期类型
time包下
3. 获取当前时间， now := time.Now()
4. time.Now().Day()，time.Now().Minute()，time.Now().Month()，time.Now().Year()


## 指针类型

1. 普通类型，变量存的就是值，也叫值类型
2. 获取变量的地址，用&，比如： var a int, 获取a的地址：&a
3. 指针类型，变量存的是一个地址，这个地址存的才是值
4. 获取指针类型所指向的值，使用：*，比如：var *p int, 使用*p获取p指向的值

值类型包括:基本数据类型 int 系列, float 系列, bool, string 、数组和结构体 struct

举个例子
```go
// 输出一个普通变量的地址
var a int = 10
fmt.Println(&a)
// 输出0xc000014080

var p *int //p是指针类型 p存储的地址值
p = &a // 将a的地址赋值给p

fmt.Println("the address of p:", &p) // 指针的内存地址
fmt.Println("the value of p:", p)    // 指针的内容
fmt.Println("the value of p point to variable:", *p) //指针指向的具体值
```

## 流程控制

### if分支流程

```go
if condition1 {
    
} else if condition2 {

} else if condition3 {
} else {
}
```
if分支的例子，将输入的字符串转换成数字，如果转换失败就输出失败信息，转换成功就是数字
```go
func main() {
	var str string
	fmt.Scanf("%s", &str)

	number, err := strconv.Atoi(str)
	if err != nil {
		fmt.Println("convert failed, err:", err)
		return
	}

	fmt.Println(number)
}
```

### switch

```go
switch var {
case var1:
case var2:
case var3:
default:
}
```

swtich case 可以使用`fallthrough` 如果在case语句块后添加fallthrough 则会继续执行下一个case。默认值只能穿透一层

```go
func main() {
	var n int
	n = rand.Intn(100)

	for {
		var input int
		fmt.Scanf("%d\n", &input)
		flag := false
		switch {
		case input == n:
			fmt.Println("you are right")
			flag = true
		case input > n:
			fmt.Println("bigger")
		case input < n:
			fmt.Println("less")
		}

		if flag {
			break
		}
	}
}

```

### for语句

```go
for 初始化语句; 条件判断; 变量修改 {
}
```

for的几种写法，上述是普通类型
写法2: 相当于while
```go
for  条件 {
}

```
写法3:for range
```go
str := “hello world,中国”
for i, v := range str {
     fmt.Printf(“index[%d] val[%c] len[%d]\n”, i, v, len([]byte(v)))
}

```
**用来遍历数组、slice、map、chan**

## goto和label

```go
func main() {
LABEL1:
	for i := 0; i <= 5; i++ {
		for j := 0; j <= 5; j++ {
			if j == 4 {
				continue LABEL1
			}
			fmt.Printf("i is: %d, and j is: %d\n", i, j)
		}
	}
}

```

```go
func main() {
	i := 0
HERE:
	print(i)
	i++
	if i == 5 {
		return
	}
	goto HERE
}

```
实际上 break和continue 也可以指定标签

## 函数

声明语法：func 函数名 (参数列表) [(返回值列表)] {}

golang函数特点：
a.不支持重载，一个包不能有两个名字一样的函数
b.函数是一等公民，函数也是一种类型，一个函数可以赋值给变量
c.匿名函数
d.多返回值

函数的赋值
```go
type op_func func(int, int) int

func add(a, b int) int {
	return a + b
}

func sub(a, b int) int {
	return a - b
}

func operator(op op_func, a, b int) int {

	return op(a, b)
}

func main() {
	var a, b int
	add(a, b)

	var c op_func
	c = add
	fmt.Println(add)
	fmt.Println(c)

	sum := operator(c, 100, 200)
	fmt.Println(sum)
}
```

函数参数传递的方式
1.值传递
2.引用传递

注意1：无论是值传递，还是引用传递，传递给函数的都是变量的副本，
不过，值传递是值的拷贝。引用传递是地址的拷贝，一般来说，地址拷贝更为高效。而值拷贝取决于拷贝的对象大小，对象越大，则性能越差。

注意2：map、slice、chan、指针、interface默认以引用的方式传递

//Go函数不支持函数重载
//在 Go 中，函数也是一种数据类型，可以赋值给一个变量，则该变量就是一个函数类型的变量 了。通过该变量可以对函数调用
//函数既然是一种数据类型，因此在 Go 中，函数可以作为形参，并且调用

//为了简化数据类型定义，Go 支持自定义数据类型
//基本语法:type 自定义数据类型名 数据类型 
//理解: 相当于一个别名 案例:type myInt int 
//这时 myInt 就等价 int 来使用了.

## 匿名函数

Go 支持匿名函数，匿名函数就是没有名字的函数，如果我们某个函数只是希望使用一次，可以考 虑使用匿名函数，匿名函数也可以实现多次调用

```go
  //1. 在定义匿名函数时就直接调用，这种方式匿名函数只能调用一次
	res1 := func(n1 int, n2 int) int {
		return n1 + n2
	}(10, 20)

	fmt.Println("res1=", res1)

	//2. 将匿名函数赋给一个变量(函数变量)，再通过该变量来调用匿名函数 

	myFunc := func(n1 int, n2 int) int {
		return n1 + n2
	}

	res3 := myFunc(10, 30)
	fmt.Println("res3=", res3)
```

## 内置函数
Golang 设计者为了编程方便，提供了一些函数，这些函数可以直接使用，我们称为 Go 的内置函 数。
文档:https://studygolang.com/pkgdoc -> builtin

Go语言层面支持的，不需要导入包

1.close：主要用来关闭channel
2.len：用来求长度，比如String，array，slice，map，channel
3.new：用来分配内存，主要用来分配值类型，比如int struct。返回的是指针
4.make：用来分配内存，主要用来分配引用类型，比如chan，map，slice
[new和make的区别](https://www.flysnow.org/2017/10/23/go-new-vs-make.html)
5.append：用来追加元素到数组/slice中

```go
	var a []int
	a = append(a, 10, 20, 383)
	a = append(a, a...) // a... 表示展开一个切片，语法糖 甜
	fmt.Println(a)
```
6.panic和recover：用来做错误处理
[Go的异常处理 defer, panic, recover](https://www.cnblogs.com/ghj1976/archive/2013/02/11/2910114.html)
[go的异常处理机制](https://segmentfault.com/a/1190000010203475)

## 异常处理
Go中引入的处理方式为:defer,panic,recover
这几个异常的使用场景可以这么简单描述:Go 中可以抛出一个 panic 的异常，然后在 defer 中
通过 recover 捕获这个异常，然后正常处理

```go
func test() {
	defer func() {
		err := recover() //内置的recover可以捕获异常
		if err != nil {
			fmt.Println("err=", err)
		}
	}()
	num1 := 10
	num := 0
	res := num1 / num
	fmt.Println("res=", res)
}
```
defer 后面是一个匿名函数

**自定义错误的介绍**
Go 程序中，也支持自定义错误， 使用 errors.New 和 panic 内置函数
errors.New("错误说明") , 会返回一个 error 类型的值，表示一个错误
panic 内置函数 ,接收一个 interface{}类型的值(也就是任何值了)作为参数。可以接收error类型的 变量，输出错误信息，并退出程序.

```go
func test02() (err error) {
	return errors.New("发生错误")
}

func test03() {
	err := test02()
	if err != nil {
		panic(err)
	}
}
```

## 递归函数

设计原则：
1.一个大的问题 可以拆分很多的小问题
2.定义好出口条件

## defer
//在函数中，程序员经常需要创建资源(比如:数据库连接、文件句柄、锁等) ，为了在函数执行完毕后，及时的释放资源，
//Go 的设计者提供 defer (延时机制)
执行顺序，有点类似final


//细节说明
//1.当 go 执行到一个 defer 时，不会立即执行 defer 后的语句，而是将 defer 后的语句压入到一个栈 中
//[为了理解，暂时称该栈为 defer 栈], 然后继续执行函数下一个语句。
//2.当函数执行完毕后，在从 defer 栈中，依次从栈顶取出语句执行(注:遵守栈 先入后出的机制)
//3.在 defer 将语句放入到栈时，也会将相关的值拷贝同时入栈。

```go
func sum(n1 int, n2 int) int {
	//当执行到defer时暂不执行 会将defer后的语句压入defer栈
	//当函数执行完毕之后，按照先入后出的方式依次执行
	defer fmt.Println("ok n1", n1)
	defer fmt.Println("ok n2", n2)

	//defer值拷贝
	n1++
	n2++

	res := n2 + n1
	fmt.Println("ok res", res)
	return res
}
```
//最佳实践
//1.defer 最主要的价值是在，当函数执行完毕后，可以及时的释放函数创建的资源。
//2.在 golang 编程中的通常做法是，创建资源后，比如(打开了文件，获取了数据库的链接，或者是
//锁资源)， 可以执行 defer file.Close() defer connect.Close()
//3.在 defer 后，可以继续使用创建资源.
//4.当函数完毕后，系统会依次从 defer 栈中，取出语句，关闭资源.
//5.这种机制，非常简洁，程序员不用再为在什么时机关闭资源而烦心

## 值传递和引用传递

我们在讲解函数注意事项和使用细节时，已经讲过值类型和引用类型了，这里我们再系统总结一 下，
因为这是重难点，值类型参数默认就是值传递，而引用类型参数默认就是引用传递。
其实，不管是值传递还是引用传递，传递给函数的都是变量的副本，不同的是，值传递的是值的
拷贝，引用传递的是地址的拷贝，一般来说，地址拷贝效率高，因为数据量小，而值拷贝决定拷贝的 数据大  
小，数据越大，效率越低。

**值类型和引用类型**
值类型:基本数据类型 int 系列, float 系列, bool, string 、数组和结构体 struct
引用类型:指针、slice 切片、map、管道 chan、interface 等都是引用类型


下面的语句等价与赋值语句 赋值语句不能在函数体外部,无法通过编译
Name := "Tom"


**细节说明**
1.值类型默认是值传递，变量直接存储值，内存通常在栈中分配
2.引用类型默认是引用传递，变量存储的是一个地址，变量存储的是一个地址，这个地址对应的空间才是真
正存储数据的值。内存通常在堆上分配，当没有任何变量引用这个数据的时候，会被GC回收
3. 如果希望函数内的变量能修改函数外的变量，可以传入变量的地址&，函数内以指针的方式操作变量。从效果上看类似引用。

## 闭包

闭包就是一个函数和与其相关的引用环境组合的一个整体(实体)

```go
func main() {
	f := AddUpper()
	fmt.Println(f(1))
	fmt.Println(f(2))
	fmt.Println(f(3))
}

func AddUpper() func (int) int {
	var n int = 10
	return func (x int) int {
		n = n + x
		return n
	}
}
```

**细节说明**
1.AddUpper 是一个函数，返回的数据类型是 fun (int) int
2.返回的是一个匿名函数, 但是这个匿名函数引用到函数外的n,因此这个匿名函数就和n形成一 个整体，构成闭包。
3.大家可以这样理解: 闭包是类, 函数是操作，n 是字段。函数和它使用到 n 构成闭包
4.当我们反复的调用 f 函数时，因为 n 是初始化一次，因此每调用一次就进行累计。
5.我们要搞清楚闭包的关键，就是要分析出返回的函数它使用(引用)到哪些变量，因为函数和它引
用到的变量共同构成闭包。
6.对上面代码的一个修改，加深对闭包的理解

## 数组和切片

### 数组
在go中 数组是值类型
格式：`var 数组名 [数组大小]数据类型`

**数组的初始化**

```go
//四种初始化数组的方式
	var numArr01 [3]int = [3]int{1,2,3}
	fmt.Println("numArr01", numArr01)

	var numArr02 = [3]int{5,6,7}
	fmt.Println("numArr02", numArr02)

	var numArr03 = [...]int{8,9,10}
	fmt.Println("numArr03", numArr03)

   //设置指定pos的value
	var numArr04 = [...]int{1:800, 0:900, 2:999}
	fmt.Println("numArr04", numArr04)
```

**遍历数组的几种方式**
1.常规遍历
```go
for i := 0; i < len(hens); i++ {
		totalWeight += hens[i]
	}
```
2.for range遍历
```go
for _, val := range(strArr) {
		fmt.Printf("值分别是%v", val)
	}
```
for--range的基本语法
	1. 第一个返回值index是下标
	2. 第二个返回值value是该下标位置的值
	3. 他们都是for循环内部可见的变量
	4. 如果不想使用index可以使用_代替
	5. index和value可以取其他名字

**数组注意事项**
1.数组是多个相同类型数据的组合,一个数组一旦声明/定义了,其长度是固定的, 不能动态变化
2. var arr []int 这时 arr 就是一个 slice 切片，切片后面专门讲解，不急哈.
3. 数组中的元素可以是任何数据类型，包括值类型和引用类型，但是不能混用。
4. 数组创建后，如果没有赋值，有默认值(零值)
5. 使用数组的步骤 1. 声明数组并开辟空间 2 给数组各个元素赋值(默认零值) 3 使用数组
6. 数组的下标是从 0 开始的
7. 数组下标必须在指定范围内使用，否则报 panic:数组越界，比如
8. Go的数组属值类型，在默认情况下是值传递，因此会进行值拷贝。数组间不会相互影响
9.长度是数组类型的一部分，在传递函数参数时 需要考虑数组的长度

**细节说明**
数组的地址可以通过数组名来获取 &arr
数组的第一个元素的地址，就是数组的首地址
数组的各个元素的地址间隔是依据数组的类型决定，比如 int64 -> 8 int32->4

### 切片
**啥？切啥**
切片的英文是 slice
切片是数组的一个引用，因此**切片是引用类型**，在进行传递时，遵守引用传递的机制。
切片的使用和数组类似，遍历切片、访问切片的元素和求切片长度 len(slice)都一样。
切片的长度是可以变化的，因此切片是**一个可以动态变化数组**。

切片定义的基本语法: `var 切片名 []类型`

**切片的初始化**



