# Go-流程控制


## if分支流程

基本语法

```
if 条件表达式{
    执行代码块
}
```

## swith分支流程控制

基本语法

```
switch 表达式{
    case:表达式1,表达式2,....:
        语句块1
    case:表达式1,表达式2,....:
        语句块2
    default:
        语句块
   
}
```

1.Go中case后的表达式可以是多个，使用逗号间隔
2.Go中case的语句块中不需要break。默认会有，默认情况下，执行完case的语句块就会退出switch控制
3.case/switch后是一个表达式（常量值/变量/一个**有返回值的函数**等）
4.case后各个表达式的值的数据类型，必须和switch的表达式数据类型一致
5.case后面的表达式如果是常量值（字面量），则要求不能重复
6.switch 穿透`fallthrough` 如果在case语句块后添加fallthrough 则会继续执行下一个case
  默认值只能穿透一层
7.Type Switch switch还可以被用于 type-switch 来判断某个interface变量中实际指向的变量类型

```go
var x interface{}
var y = 10.0
x = y
switch i :=x.(type){
  case nil:
  fmt.Printf("x的类型：%T",i)
  case int:
  fmt.Printf("x是int")
  case float64:
  fmt.Printf("x是float")
}
```

## for循环控制

基本语法

```
for 循环变量的初始化;循环条件;循环变量迭代{
    循环操作语句
}
```

for-range遍历方式 有点像前端框架的`for-in`

```go
var str = "abc~ok上海"
for index,val :=range str {
    fmt.Printf("index=%d, val=%c \n",index,val)
}
```

1.break语句出现在多层嵌套的语句块中时，可以**通过标签**指明要终止的是哪一层语句块
2.break 默认跳出最近的for循环

```go
label2:
for i:= 0; i<10; i++{
    lable1:
    for j :=0; j<10; j++{
        break lable2
    }
    fmt.Println("j=",j)
}
```

## while和do..while的实现

Go没有while和do while语法 需要使用for进行实现

## 跳转控制语句 goto
 
1.Go语言的goto语句可以无条件地转移到程序中指定的行
2.goto语句通常与条件语句配合使用。可以用来实现条件转移，跳出循环体等功能
3.在Go程序设计中 一般不主张使用goto语句，以免造成程序流程的混乱，使理解和调试程序都产生困难

```go
var n int = 30
	演示goto的使用
	fmt.Println("ok1")
	if n > 20 {
		goto label1
	}
	fmt.Println("ok2")
	fmt.Println("ok3")
	fmt.Println("ok4")
	label1:
	fmt.Println("ok5")
	fmt.Println("ok6")
	fmt.Println("ok7")
```


