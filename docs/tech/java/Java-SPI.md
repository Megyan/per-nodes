Java中的SPI机制

## SPI是什么
SPI全称Service Provider Interface，是Java提供的一套用来被第三方实现或者扩展的API，它可以用来启用框架扩展和替换组件

`Java SPI 实际上是“基于接口的编程＋策略模式＋配置文件”组合实现的动态加载机制`

SPI的核心思想就是**解耦**

## 使用场景
概括地说，适用于：**调用者根据实际使用需要，启用、扩展、或者替换框架的实现策略**
比较常见的例子：

```
 1.数据库驱动加载接口实现类的加载 JDBC加载不同类型数据库的驱动
 2.日志门面接口实现类加载 SLF4J加载不同提供商的日志实现类
 3.Spring中大量使用了SPI,比如：对servlet3.0规范对ServletContainerInitializer的实现、自动
 类型转换Type Conversion SPI(Converter SPI、Formatter SPI)等
 4.Dubbo中也大量使用SPI的方式实现框架的扩展, 不过它对Java提供的原生SPI做了封装，允许用户扩展实
 现Filter接口
```

## 使用介绍

#### 约定
要使用Java SPI，需要遵循如下约定：

* 1、当服务提供者提供了接口的一种具体实现后，在jar包的META-INF/services目录下创建一个以“接口全限定名”为命名的文件，内容为实现类的全限定名；
* 2、接口实现类所在的jar包放在主程序的classpath中；
* 3、主程序通过java.util.ServiceLoder动态装载实现模块，它通过扫描META-INF/services目录下的配置文件找到实现类的全限定名，把类加载到JVM；
* 4、SPI的实现类必须携带一个不带参数的构造方法；


> S p = service.cast(c.newInstance()); 这行挺有意思的
#### 使用

```
1.定义一组接口 (假设是org.foo.demo.IShout)，并写出接口的一个或多个实现，(假设是org.foo.demo.animal.Dog、org.foo.demo.animal.Cat)
2.在 src/main/resources/ 下建立 /META-INF/services 目录， 新增一个以接口命名的文件 (org.foo.demo.IShout文件)，内容是要应用的实现类（这里是org.foo.demo.animal.Dog和org.foo.demo.animal.Cat，每行一个类
3.使用 ServiceLoader 来加载配置文件中指定的实现
```

```java
public class SPIMain {
    public static void main(String[] args) {
        ServiceLoader<IShout> shouts = ServiceLoader.load(IShout.class);
        for (IShout s : shouts) {
            s.shout();
        }
    }
}
```

### 总结
**优点：**

使用Java SPI机制的优势是实现解耦，使得第三方服务模块的装配控制的逻辑与调用者的业务代码分离，而不是耦合在一起。应用程序可以根据实际业务情况启用框架扩展或替换框架组件。

**缺点：**
虽然ServiceLoader也算是使用的延迟加载，但是基本只能通过遍历全部获取，也就是接口的实现类全部加载并实例化一遍。如果你并不想用某些实现类，它也被加载并实例化了，这就造成了浪费。获取某个实现类的方式不够灵活，只能通过Iterator形式获取，不能根据某个参数来获取对应的实现类。
多个并发多线程使用ServiceLoader类的实例是不安全的


**参考**
<https://juejin.im/post/5b9b1c115188255c5e66d18c>

 

