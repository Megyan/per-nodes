Java的糖-Lambda 面向行为的抽象
## 为什么需要Lambda

## Lambda 初见
**通常使用语法：**

(argument) -> (body)

**Lambda 表达式的结构：**

* Lambda 表达式可以具有零个，一个或多个参数。
* 可以显式声明参数的类型，也可以由编译器自动从上下文推断参数的类型。例如 (int a) 与刚才相同 (a)。
* 参数用小括号括起来，用逗号分隔。例如 (a, b) 或 (int a, int b) 或 (String a, int b, float c)。
* 空括号用于表示一组空的参数。例如 () -> 42。
* 当有且仅有一个参数时，如果不显式指明类型，则不必使用小括号。例如 a -> return a*a。
* Lambda 表达式的正文可以包含零条，一条或多条语句。
* 如果 Lambda 表达式的正文只有一条语句，则大括号可不用写，且表达式的返回值类型要与匿名函数的返回类型相同。
* 如果 Lambda 表达式的正文有一条以上的语句必须包含在大括号（代码块）中，且表达式的返回值类型要与匿名函数的返回类型相同

从形式上看，lambda是传递了参数列表和方法体。而实际上还是一个匿名内部类。
 
## 方法引用
方法引用的唯一用途是支持Lambda的简写，使用方法名称来表示Lambda

**引用静态方法**`ContainingClass::staticMethodName` 

```
例子: String::valueOf，对应的Lambda：(s) -> String.valueOf(s) 
比较容易理解，和静态方法调用相比，只是把.换为::
```

**引用特定对象的实例方法** `containingObject::instanceMethodName`

```
例子: x::toString，对应的Lambda：() -> this.toString() 
与引用静态方法相比，都换为实例的而已
```

**引用特定类型的任意对象的实例方法** `ContainingType::methodName`

```
例子: String::toString，对应的Lambda：(s) -> s.toString() 
太难以理解了。难以理解的东西，也难以维护。建议还是不要用该种方法引用。 
实例方法要通过对象来调用，方法引用对应Lambda，Lambda的第一个参数会成为调用实例方法的对象。
```
**引用构造函数**`ClassName::new`

```
例子: String::new，对应的Lambda：() -> new String() 
构造函数本质上是静态方法，只是方法名字比较特殊。
```
**Funtion的使用**

```
// 获取 getAge 方法的 Function 对象
Function<Person, Integer> getAge = Person::getAge;
// 传参数调用 getAge 方法
Integer age = getAge.apply(p);
```
**参考：**


## 功能接口
在 Java 中，功能接口（Functional interface）指**只有一个抽象方法**的接口。

@FunctionalInterface 是在 Java 8 中添加的一个新注解，用于指示接口类型，声明接口为 Java 语言规范定义的功能接口。Java 8 还声明了 Lambda 表达式可以使用的功能接口的数量。当您注释的接口不是有效的功能接口时， @FunctionalInterface 会产生编译器级错误


```
package com.wuxianjiezh.demo.lambda;

@FunctionalInterface
public interface WorkerInterface {

    public void doWork();
}

class WorkTest {

    public static void main(String[] args) {
        // 通过匿名内部类调用
        WorkerInterface work = new WorkerInterface() {
            @Override
            public void doWork() {
                System.out.println("通过匿名内部类调用");
            }
        };
        work.doWork();
        
        // 通过 Lambda 表达式调用
        // Lambda 表达式实际上是一个对象。
        // 我们可以将 Lambda 表达式赋值给一个变量，就可像其它对象一样调用。
        work = ()-> System.out.println("通过 Lambda 表达式调用");
        work.doWork();
    }
}
```
## Lambda的日常使用
* 1.线程初始化
* 2.事件处理
* 3.遍例输出（方法引用）
* 4.逻辑操作


<https://segmentfault.com/a/1190000009186509>


