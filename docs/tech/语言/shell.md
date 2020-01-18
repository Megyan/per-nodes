# Shell
 Linux 正则表达式以及三剑客 grep、awk、sed 
 
 #!/bin/bash 表示谁来解释执行shell
 
## 1.变量的赋值

**直接赋值**
A=aaa 两边不能有空格
A='date' date命令的值就会传递给A

B=$(ls -l)
A=$B

列出所有变量 set
双引号和单引号不一样。简单的说 单引号原样返回，而双引号里可以获取变量“person is $NAME”

**间接赋值**

用户交互的变量 `read -p "gave me a number" a`

```shell
read a b c # 分别给a b c赋值
```

unset 删除变量

位置变量 `ls -l` l就是位置变量
使用$N来表示

特殊变量
$* 这个程序的所有参数
$# 这个程序参数的个数
$$ 程序PID
$! 上个程序指令的PID
$? 上个程序的返回值

```
1.接下来用户输入的值将会被赋值到a中
2.行首快捷键：gg
3.行尾：GG
4.大写的变量一般都是系统的环境变量
5.变量名推荐小写
```

### expr命令 算数表达式

Shell变量的算术运算

```shell
expr 3 + 5 # 运算符之间必须有空格
```
### 变量测试语句
test 测试条件
测试范围 整数 字符串 文件

```shell
test str1==str2
test str1!=str2
test str1 # 是否 非空
test -n str1 # 是否为空

test n1 -eq n2 # 数字是否相等
```
也可以省略test 写成 `[ 2 -ne 3 ] ` **下面就是这么写的哦**

```shell
test -d file # 是否是目录
test -f file # 是否是文件
test -x file # 可以简写成 [-x file]

test -e file # 文件是否存在 
test -s file # 测试文件大小是否为空 即是否是空文件
```


### 逻辑语句
-a 等价于 &&
-o 等价于 ||
 
### if语句
if语法
```
if 条件
then
    语句
fi
```

```shell
if [-x /bin/ls]; then
/bin/ls
fi
```

if-else语法

```
if 条件;then
    命令1
else
    命令2
fi   
```

```
if 条件;then
    命令1
elif 条件2;then
    命令3
else
    命令2
fi   
```

来个综合例子

```shell
echo "input a file name"
read file_name
if [-d $file_name];then
    echo "$file_name is a dir"
elif [-f $file_name];then
    echo "$file_name is a file"
elif [-c $file_name -o -b $file_name];then
    echo "$file_name is a device file"
else
    echo "$file_name is a unknow filw"
fi 
```

## case for while 循环

case 流控制语句
循环语句 for done语句
使用(())扩展shell中算数运算使用方法
跳出循环 break和continue
Shift参数左移命令
shell中函数使用方法

### case

流程控制语句
适用于多分支

```
case in 变量
字符串1) 命令列表1
;;
...
字符串n) 命令列表n
;;
esac
```

举个例子

```shell
read op
case $op in
c) echo "your selection is copy"
;;
D) echo "your selection is del"
;;
B) echo "your selection is backup"
;;
*) echo "invalide selection" # * 通配符 匹配所有参数
esac
```

### for done

```
for 变量 in 名字表
do
    命令列表
done
```

```shell
for DAY in Sunday Monday Tuesday Wednedday Thursday Firday Saturday
do
    echo "The day is:$DAY"
done  
```

### while

```
while 条件
do
    命令列表
done
```
求10以内的平方和

```shell
#!/bin/bash
num=1
while [ $num -le 10]
do
    square='expr $num \* $num'
    echo $square
    num='expr $num+1'
done
```

### 小括号(())扩展算数运算的使用方法
使用"[]"的时候，必须**保证算数和算数运算符之间有空格**。四则运算也只能借助 `expr` 命令来完成。
而双括号就是对shell中算数及赋值运算的扩展

```
((表达式1,表达式2...))
```
1.在双括号结构中，所有表达式可以像C语言一样，如：a++ b--等
2.所有变量可以不加入 “$”符号前缀
3.可以进行逻辑运算，四则运算
4.扩展了for while if 条件测试运算
5.支持多个表达式运算，各个表达式之间使用逗号","分开

输出小于100，2的幂。如2 4 8 16...

```shell
#!/bin/bash
NUM=1
while((NUM<100))
do
    echo "Num is :$NUM";
    ((NUM=NUM*2))
done
```


### 循环的嵌套

`echo -n "aaaa"` 输出后不换行
`echo *` 匹配当前目录下所有文件名称 也就是输出了当前目录下所有文件名称

`read Line` 接受键盘输入的内容
`read -p “输入内容：” Line` 给出提示，接受键盘输入的内容

来，举个例子

```shell
#!/bin/bash
read -p "输入行号：" Line
read -p "输入字符：" Char
a=1
while [$a -le $Line]
do
    b=1
    while[$b -le $a]
    do
        echo -n "$Char"
        b = 'expr $b+1'
    done
    echo # 换行 
    a='expr $a+1'
done
```

### break-continue

## Shell命令的用法

将window中的脚本导入到Linux系统报错
Shift 参数左移命令
shell 中函数的使用办法
shell 脚本实践 mysql自动备份和自动解压ZIP文件

### shift 命令
每执行一次 参数序列顺次左移一位，$#的值减一，用于分别处理每个参数，移出的参数不可再用。
有点像出队的意思。`$#` 保存了所有的参数的队列，`shift`相当于`pop`。

做一个加法计算器 计算所有参数的和。
```shell
#!/bin/bash
if [$# -le 0]
  then
  echo "err!：Not enough parameters"
  exit 124
fi
sum = 0
while [$# -gt 0]
do
   sum='expr $sum + $1'
    shift
done
echo $sum 
```

### shell 函数
函数的定义：

```
function 函数名() # function 可以不写
{
    命令序列
}
```

函数调用时 不带()。调用语法：`函数名 参数1 参数2 ...`

函数中的变量均为全局变量，没有局部变量。调用函数时，可以传递参数。在函数中使用 `$1 $2` 来引用传递的参数。

```shell
#! /bin/bash
abc=123
echo $abc
function exchange()
{
    abc=456
}
exchange #函数的调用
echo $abc
```

函数参数的传递

```shell
#！/bin/bash
example2()
{
    echo $1
    echo $2
}

example2 aaa bbb # 函数调用

```
### mysql自动备份

反引号间的内容，会被shell先执行。其输出被放入主命令后，主命令再被执行。

```shell
# !/bin/sh
BAKDIR=/data/backup/mysql/`date+%Y-%m-%d`
MYSQLDB=test
#MYSQLDB=webapp #要备份的数据库
MYSQLUSER=root
#MYSQLPW=webapp #要备份的数据库密码

if
  [$UID -ne 0];then
  echo This script must use the root user!
  sleep 2
  exit 0
fi

# 判断目录是否存在 不存在就创建
if
  [! -d $BAKDIR];then
  mir -p $BAKDIR
else
  echo This is $BAKDIR exists
fi

# 使用mysqldump备份数据库
/usr/bin/mysqldump -u$MYSQLUSR -d $MYSQLDB >$BAKDIR/webapp_db.sql
# 压缩
cd $BACKDIR ; tar -czf webapp_mysql_db.tar.gz *.sql
# 查找备份目录下以.sql 结尾的文件并删除
# find . type f -name *.sql | xargs rm -fr # 这行命令也可以删除
find . -type f -name *.sql -exec rm -rf {} \;

# 如果备份成功 则打印成功 并删除备份目录30天以前的目录
[$? -eq 0] && echo "This `date + %Y -%m-%d` Mysql BACKUP is SUCCESS"
cd /data/backup/mysql/ ; find . -type d -mtime +30 | xargs rm -rf
echo "the mysql backup successfully"
  
```

## 自动解压ZIP包的脚本

```shell
PATH1=/shell/zip
PATH2=/shell/unzip
# Print welcome info
cat <<EOF
++-------------------++
++----Welcome to ----++
++-------------------++
EOF

# 查找PATH1目录下所有zip包，并解压到目录PATH2下
cd $PATH1
for i in `find . -name "*.zip" | awk -F. '{print $2}'`
do
   unzip -o .$i.zip -d $PAHT2$i
done
```

awk -F. '{print $2}' #awk 列操作
-F. 以.作为分隔符
print 输出
$2 表示第2列
 
## 2.两个常用的内置变量

 **echo $UID**  `判断当前用户是否root用户，root用户UID为0 `

 **echo $?**` 判断上一条命令执行是否成功，输出为0表示执行成功，非i0表示执行不成功`

## 3.比较数字的两种方法

* [] `内部编写比较逻辑.[]中括号两边一定要有空格`

* &&  || 连接符号 ` [ 2 -ne 3 ] && echo 0 || echo 1 表示2是不是不等于3，不等于输出0，等于输出1`

  >  &&  和 || 都是连接符号 。&& 表示前边的命令执行正确后，执行。||  表示前边的命令失败后执型

* 比较符号

```
-eq：等于  -ne：不等于 -lt：小于 -gt：大于 

-ge：大于等于 -le：小于等于 
```

赋值 line = ‘cat 99.sh | wc -l’ 此时的line表示99.sh文件的行数

## 4.比较字符串的方法

```shell
var=qwer [[ $var="qwer" ]] && echo 1 || echo 0
```
**比较字符串用[[ ]]，-eq只能比较数字**
比较字符串是可以使用正则表达式的

```
[ -z $var ] 判断变量是否为空值
```

## 8.中括号的几种用法

```shell
[ ! -z $var ] 变量是不是 不是空值 
[ -d $dir ] 路径是不是存在
[ -f $file ] 文件是不是存在
```
-d:判断目录 -f:判断文件 -x:判断执行权限

## 9.函数简介

shell 脚本很少传参 `就是方法基本没有参数列表`
exit 1 非正常退出

## 10.位置变量

**常用的位置变量** 

* $0: 脚本本身的路径
* $1：第一个参数
* $2：第二个参数
* $# ：参数是几个
* $@：所有参数

```shell
[ $# -ne 1 ] && echo 'need $1' && exit 1
ip=$1
ping -c 2 -w 2 $ip > /dev/null 2>&1 
[ $? -eq 0 ] && echo "$ip is on 
```
 -c 执行次数
 -w 超时等待
 2>&1 异常重定向？？
 ping指定ip两次，超时时间为2秒。异常信息输出
 

