# Go-变量

## 变量的使用

```go
package main
import "fmt"

func main() {
	//定义变量/声明变量
	var i int
	//给i 赋值
	i = 10
	//使用变量
	fmt.Println("i=", i)
}
```

## 变量使用的注意事项

1.变量表示内存中的一个存储区域
2.该区域由自己的名称（变量名）和类型（数据类型）
3.Golang变量使用的三种方式
    a 第一种：指定变量类型，声明后若不赋值，使用默认值
    b 第二种：根据值 自行判断类型 **类型推倒**
    c 第三种：省略 var。注意 `:=` 左边的变量不应该是声明过的，否则会编译错误
   

```go
package main
import "fmt"

func main() {
	//golang的变量使用方式1
	//第一种：指定变量类型，声明后若不赋值，使用默认值
	// int 的默认值是0 , 其它数据类型的默认值后面马上介绍
	var i int 
	fmt.Println("i=", i)

	//第二种：根据值自行判定变量类型(类型推导)
	var num  = 10.11
	fmt.Println("num=", num)

	//第三种：省略var, 注意 :=左侧的变量不应该是已经声明过的，否则会导致编译错误
	//下面的方式等价 var name string   name = "tom"
	// := 的 :不能省略，否则错误
	name := "tom"
	fmt.Println("name=", name)

}
```

 d 多变量声明
 
 ```go
 package main
import "fmt"

//定义全局变量
var n1 = 100
var n2 = 200
var name = "jack"
//上面的声明方式，也可以改成一次性声明
var (
	n3 = 300
	n4 = 900
	name2 = "mary"
)

func main() {
	
	//该案例演示golang如何一次性声明多个变量
	// var n1, n2, n3 int 
	// fmt.Println("n1=",n1, "n2=", n2, "n3=", n3)

	//一次性声明多个变量的方式2 
	// var n1, name , n3 = 100, "tom", 888
	// fmt.Println("n1=",n1, "name=", name, "n3=", n3)

	//一次性声明多个变量的方式3, 同样可以使用类型推导
	// n1, name , n3 := 100, "tom~", 888
	// fmt.Println("n1=",n1, "name=", name, "n3=", n3)

	//输出全局变量
	//fmt.Println("n1=",n1, "name=", name, "n2=", n2)
	fmt.Println("n3=",n3, "name2=", name2, "n4=", n4)

}
 ```
 
 6.该区域的数值可以在**同一类型内**不断变化
 
 7.变量在同一作用域（一个函数或者代码块内）不能重复声明
 
 8.变量 = 变量名 + 值 + 数据类型 变量的三要素
 
 9.变量如果没有赋初值，编译器就会使用默认值，比如 int默认值0
 
## 变量的声明，初始化和赋值

<font color=#A52A2A>**声明变量**</font>
基本语法 `var 变量名 数据类型`

<font color=#A52A2A>**初始化**</font>
声明变量的时候 就给值
var a int = 45 这就是初始化变量a
使用细节，如果声明变量时就直接赋值，可省略数据类型
var b = 400

<font color=#A52A2A>**初始化**</font>
先声明了变量：var num int //默认0
赋值 num = 780

## 数据类型介绍

```plantuml
[数据类型] as all

[基本数据类型] as baseType
[数值型] as number
[整数型] as int

note left of int
int int8 int16 int32 
int64 unit unit8 unit32 unit64 
byte
end note

[浮点型] as float
[字符型] as byte

note left of byte
没有专门的字符型，使用byte来保存单个字母字符
end note

[布尔型] as bool
[字符串string] as str

[派生/复杂类型] as complex
note left of complex
1.指针（Pointer）
2.数组
3.结构体（strut）
4.管道（Channel）
5.函数
6.切片（slice）
7.接口（inerface）
8.map
end note

all --> baseType
all --> complex
baseType --> number
number --> int
number --> float
baseType --> byte
baseType --> bool
baseType --> str

```

## 整数类型

1.Golang整数类型分：有符号 无符号 int uint的大小跟操作系统有关
2.Golang默认的整型类型是 int
3.如何在程序查看某个变量的字节大小和数据类型

```go
var n2 uint64 = 10
fmt.Printf("n2 的类型 %T  n2占用的字节数%d",n2,unsafe.Sizeof(n2))
```

## 浮点类型

1.Golang 浮点类型有固定范围和字段长度，不受具体OS影响
2.Golang 浮点类型默认float64

## 字符类型

Go中没有专门的字符类型，如果要存储单个字符，**一般使用byte来保存**
字符串就是一串固定长度的字符连接起来的字符序列。
与传统的字符串不同，Go的字符串是有**字节**组成的。

 
## String类型

1.Go的字符串的字节使用UTF-8编码标识Unicode文本。
2.字符串的两种表示形式
  双引号 会识别转义字符
   
  ```go
   str2 := "abc\nabc"
   fmt.Println(str2)
  ```
  反引号 以字符串的原生形式输出，包括换行和特殊字符，可以防止攻击/输出源代码等效果
  
  ```go
  str3 := ` 
	package main
	import (
		"fmt"
		"unsafe"
	)
	
	//演示golang中bool类型使用
	func main() {
		var b = false
		fmt.Println("b=", b)
		//注意事项
		//1. bool类型占用存储空间是1个字节
		fmt.Println("b 的占用空间 =", unsafe.Sizeof(b) )
		//2. bool类型只能取true或者false
		
	}
	`
	fmt.Println(str3)

  ```

## 基本类型的默认值


| 数据类型 | 默认值 | 
| --- | --- | 
| 整型 | 0 |  
| 浮点型 | 0 | 
| 字符串 | “” | 
| 布尔类型 | false | 

## 基本数据类型的相互转换

Go和java不同 Go在不同类型的变量之间赋值时**需要显式转换**

表达式 `T(v)` 将值v转换为类型T

```go
  var i int32 = 100
	//希望将 i => float
	var n1 float32 = float32(i)
	var n2 int8 = int8(i)
	var n3 int64 = int64(i) //低精度->高精度

	fmt.Printf("i=%v n1=%v n2=%v n3=%v \n", i ,n1, n2, n3)
```
1.Go中，类型转换可以从 表示范围小-->范围大，也可以表示范围大-->范围小

2.在转换中，比如将int64 转成 int8 [-128～128]，编译不会报错，只是转换结果按照溢出处理，和我们期望的结果不一样。因此在转换中，需要考虑范围。

## 基本数据类型和String的转换

### 基本类型转String
1.fmt.Sprintf("%参数"，表达式)

```go
  var a int // 0
	var b float32 // 0
	var c float64 // 0
	var isMarried bool // false 
	var name string // ""
	//这里的%v 表示按照变量的值输出
	fmt.Printf("a=%d,b=%v,c=%v,isMarried=%v name=%v",a,b,c,isMarried, name)
```

2.使用strconv包的函数

```go
//第二种方式 strconv 函数 
	var num3 int = 99
	var num4 float64 = 23.456
	var b2 bool = true

	str = strconv.FormatInt(int64(num3), 10)
	fmt.Printf("str type %T str=%q\n", str, str)
	
	// strconv.FormatFloat(num4, 'f', 10, 64)
	// 说明： 'f' 格式 10：表示小数位保留10位 64 :表示这个小数是float64
	str = strconv.FormatFloat(num4, 'f', 10, 64)
	fmt.Printf("str type %T str=%q\n", str, str)

	str = strconv.FormatBool(b2)
	fmt.Printf("str type %T str=%q\n", str, str)

	//strconv包中有一个函数Itoa
	var num5 int64 = 4567
	str = strconv.Itoa(int(num5))
	fmt.Printf("str type %T str=%q\n", str, str)
```


### string转其他类型

```go
var str string = "true"
	var b bool
	// b, _ = strconv.ParseBool(str)
	// 说明
	// 1. strconv.ParseBool(str) 函数会返回两个值 (value bool, err error)
	// 2. 因为我只想获取到 value bool ,不想获取 err 所以我使用_忽略
	b , _ = strconv.ParseBool(str)
	fmt.Printf("b type %T  b=%v\n", b, b)
	
	var str2 string = "1234590"
	var n1 int64
	var n2 int
	n1, _ = strconv.ParseInt(str2, 10, 64)
	n2 = int(n1)
	fmt.Printf("n1 type %T  n1=%v\n", n1, n1)
	fmt.Printf("n2 type %T n2=%v\n", n2, n2)

	var str3 string = "123.456"
	var f1 float64
	f1, _ = strconv.ParseFloat(str3, 64)
	fmt.Printf("f1 type %T f1=%v\n", f1, f1)


	//注意：
	var str4 string = "hello"
	var n3 int64 = 11
	n3, _ = strconv.ParseInt(str4, 10, 64)
	fmt.Printf("n3 type %T n3=%v\n", n3, n3)
```

String转成基本类型，要**确保String类型能能够转成有效的数据**。
如果是想把”hello“转成数字，Go会将其转成0

## 指针

1.基本数据类型 存的是值，也叫值类型
2.获取变量的地址，用`&` 比如 var num int，获取num的地址：&num
3.指针类型 指针变量存的是一个地址，这个地址指向的空间存的才是值
  `var ptr *int = &num`

4.获取指针类型所指向的值，使用：* ，比如 `var ptr *int`，使用 `*prt` 获取的ptr指向的值

### 指针使用的细节

1.值类型，都有**对应的指针类型**，形式为 <font color=#5F9EA0>*数据类型</font>
比如 int对应的指针就是 *int， float32对应的指针类型就是 *float32，依次类推。

2.值类型包括：基本数据类型 **int系列 float系列 bool string array数组 strut结构体**

### 值类型和引用类型
值类型：基本数据类型 int系列 float系列 bool string array数组 strut结构体
值类型，变量直接存储值，内存通常在栈中分配

引用类型：指针 slice切片 map 管道chan interface等都是引用类型
变量存储的是一个地址值，这个地址对应的空间存储的内容才是真正的值。内存通常在堆上分配。当没有任何变量引用这个地址时，该地址对应的数据空间就称为一个垃圾，由GC来回收


## 键盘输入语句

1.导入 fmt 包
2.调用fmt包的 fmt.Scanln 或者 fmt.Scanf()



