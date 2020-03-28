# 深入理解Java虚拟机

## 内存管理
1.如何解决多线程分配内存空间？同步处理，CAS+重试。或者预先给每个线程分配一块空间。不够了再同步处理。

2.01既是无锁也是偏向锁的标示。如果是偏向锁，MarkWork就记录了线程ID。

3.JVM中对象有三部分，对象头，实例数据，对齐填充
>对象必然是8字节的整数倍。所以需要对齐填充。

4.内存泄漏和内存溢出
>Dump出的堆快照，可以看到GCRoot

5.GCRoot.静态属性引用的对象。方法区常量引用的对象。final

6.标记的对象不会立即回收。
>如果对象覆盖了finaliza()，则会加入F-Queue。如果在正式回收前，对象与GCRoot对象有关联，就不需要被回收了

7.CMS回收失败 `预留的空间无法满足程序的需要`，就会降级成serial收集
CMS也是可以通过参数开启空间整理的功能。

8.CMS。并发
初始标记：与GCRoot直接关联的对象
并发标记：进行GCRoot Tracing.`由前阶段标记过的对象出发，所有可到达的对象都在本阶段中标记`
重新标记：修正并发过程中，用户程序运行产生的变动
并发清除：
> 问题：因为并发 所以对CPU资源比较敏感
> 问题：GMS为了确保扫描完整，所以要扫描新生代。怎么让扫描的工作少点？先触发一次MinorGC
> CMS不一定会触发MinorGC，是有条件的：如果Eden大小>2M,启动预清理，知道可用率大于50%
> 等5s如果不发生MinorGC那就算了
[CMS详解](https://www.cnblogs.com/littleLord/p/5380624.html)

9.G1。并行切并发
>使用G1，将堆划分为多个大小相同的区域。虽然还保留新生代和老年代的概念，但是已经不是物理隔离的。
可以设置STW的时间，G1会根据时间选择回收性价比最高的区域。`G1维护了一个优先级列表`

【重要】10.GC日志
什么时间产生了GC？`开头的数字表示时间，自启动以来的秒数。`
GC的类型？ `FullGC表示产生了STW，而不是表示老年代的回收。`
GC的区域？ `DefNew ParNew 都代表新生代`
GC的效果？ `2999K->2999K(21248K) 回收前占用量->回收后占用量（最大容量）`

11.空间分配担保 `简单的说，就是年轻代GC时，问问老年代还有没有足够地方让年轻代的无法回收的对象进入` HandlePromotionFailure=true设置允许失败，就看看老年代剩余的空间大小，是否大于年轻代历次晋升到老年代的平均值。如果不大于或者不允许担保失败，直接触发FullGC


## 性能诊断工具

1.简单的命令。jps 查看java进程。 jmap 生成快照。
jstack -l 进程号 查看线程的情况
[线程状态](https://www.jianshu.com/p/31071c405e8d)


2.线程的状态流转
![](media/15851278613578/15852812990407.jpg)
![](media/15851278613578/15853129217472.jpg)

3.jConsole 内存展示的是垃圾收集的信息。可以看新生代和老年代
线程展示的jstack的内容.
可以检测死锁。

jvisualvm 线程是可视化。可以使用抽样器 实时分析内存空间的东西。
如果有死锁，线程页签会有提示。
[jvisual-死锁](https://blog.csdn.net/xidiancoder/article/details/56049315)
[jconsole和jvisualvm 死锁](https://blog.csdn.net/XiaHeShun/article/details/79926513)

4.jstack -l 如果死锁，也会有提示。
jstack定位死循环
```
top 命令进行查看top -p pid H，前几个就是 CPU占用率特别高的，记住前面的 pid数字，转成 16 进制，因为 jstack 内部表示 pid是使用 16 进制表示的。然后发开转储文件，搜索对应的 pid 号，查看具体的堆栈信息，里面包含了函数调用情况，一般来说能够大致的解决问题
```
[jstack-死锁](https://www.cnblogs.com/chenpi/p/5377445.html)

5.
UseCMSInitiatingOccupancyOnly。按照CMSInitiatingOccupancyFraction=70表明的阈值进行GC。
>如果不设置该参数，GC的时机是JVM的自身的调整。CMSInitiatingOccupancyFraction默认68
`UseConcMarkSweepGC` 使用CMS进行GC
`-XX:+UseCMSCompactAtFullCollection `在CMS垃圾收集后，进行一次内存碎片整理。
`PrintGCDetails` 输出GC的详细日志
`CMSScavengeBeforeRemark` 重新标记之前，对年轻代进行一个词minor GC。减少了GCRoot的数量

```
Xmx1024M 最大Heap的大小
Xms1024M 初始的Heap的大小。
Xmn512M 年轻代大小
Xss规定了每个线程堆栈的大小。一般情况下256K是足够了。影响了此进程中并发线程数大小。
```
[JVM 参数](https://www.cnblogs.com/redcreen/archive/2011/05/04/2037057.html)


## 类加载机制

1.类加载的过程：加载 链接 初始化
>链接里面包含：验证 准备 解析
验证就是校验Class格式。准备就是为类变量分配内存和初始化值 `这个初始化是Java的默认值，比如int类型的=0 String类型为null`。
>类变量只的是被static
字面量可以理解为实际值，int a = 8中的8和String a = "hello"中的hello都是字面量
解析：将符号引用替换成直接引用
初始化：赋值。`private int i=4;`此时执行的是将4赋值给i

2.初始化的时机：new 使用一个类的静态属性`没有被final修饰`或者调用静态方法。反射。
初始化的时候，发现其父类没有初始化，就初始化
JVM启动时候，启动类会初始化

3.类加载器不同，类就不同。
>影响equals和isInstance的结果

4.双亲委托模型。自己实现ClassLoader，只需要实现findClass
> SPI和动态加载都破坏了双亲委托模型

## 字节码的执行

1.栈帧包含的内容：局部变量表，操作数栈，动态链接，方法返回地址值

## Java内存模型与线程
1.JMM的作用是**定义程序内变量的访问规则**

2.原子操作
Read 读取。作用于主内存中的变量，是将主内存中的内容**加载到工作内容中**，以便随后的Load动作使用
Load 载入。作用于工作内存中的变量，将Read操作的值，**放入工作线程的变量副本中**。
Store 存储。作用于工作内存中的变量，将工作内存的数据写入主内存，以便后续的write操作使用。
Write 写入。作用于主内存中的变量，将store拷贝的值，放入主内存的变量中。

3.volatile是保证可见性

4.JMM的原子性。可以认为基础类型的读写是原子的。
>其实就是 Read Load Store Write Use Assgin

5.可见性。volatile sychronized final

6.有序性。volatile sychronized。
Java程序中天然的有序性，可以这么总结：如果在本线程内观察，所有操作都是有序的；如果在一个线程观察另一个线程，所有的操作都是无序的`因为指令重排和主内存和工作内存的同步延迟`。

如果所有有序性都是通过volatile sychronized 控制，那么太繁琐。所以有默认规则。

7.多线程的状态流转。5种状态。
  New
  Runnable 包含Running和Ready。要么是在运行，要么是在等待CPU为它分配运行时间。
  Waiting 无限等待。想要获得执行权，比如要被唤醒。
      ```
      没有timeout的 wait()
      没有timeout的 join()
      LockSupport.park()
      ```
  Timed Waiting。 比如Sleep Wait(100)。不用别人唤醒，我自己就上去了
  Blocked 阻塞状态和等待状态的区别是：阻塞状态是等待获取一个排他锁`它会抢锁`，但是等待状态啥也不
  干。
  Terminated 结束状态，异常或者run方法执行over
> yield( ) 让步。没有放弃锁，但是让渡了CPU的执行权。就是从Running到Ready

8.Lock和sychronized的三个区别。
  a 可中断
  b 公平锁
  c 多路通知
>synchronized的中断有两种情况：1.如果线程处于Sleep，也就是持有锁，但放弃执行权。Timed-Waiting，或者要执行阻塞操作的时候，那么线程会抛出InterruptedExection。2.如果线程一直在运行，那么该线程想要中断**必须手动判断中断状态**。
  

9.CAS。CAS的问题在于，如果自己实现么，那么如果同时有两个线程都发现结果符合预期，然后进行更改，那么更改的值，我们无法确认。
所以，比较和交换，CAS整个变成一个原子操作才可以。
[除了ABA，CAS还有什么问题](https://www.jianshu.com/p/fb6e91b013cc)

10.锁优化。锁自旋/锁消除/锁粗化/锁膨胀。
MarkWord，00是轻量锁。01偏向锁也可能是未锁定
轻量锁解决的，多线程交叉进行，不存在竞争的情况
>可以这样理解，轻量锁是将MarkWork的内容拷贝到栈空间内，并将锁对象的MarkWord更新成执行栈空间的指针。
>获取的过程是两步：1.在栈内建立锁空间 2.CAS将对象头拷贝到锁空间，同时将对象头改为指向空间的指针
>如果CAS成功，获取执行权。
>如果没有，那么检查对象头的指针是否指向自己，如果没有指向自己 说明有人捷足先登。那么将锁的标示位置改为10.同时挂起。后续的哥们都会挂起。此时重锁，阻塞。

11.轻量锁，就是更改对象头的标示位，同时将线程ID写入对象头。解决的是，根本不存在多线程，就自己玩




大量插入导致的死锁
案例0:程序
程序，


案例1:程序停止运行。
生产消费模型。现象，数据没有更新 图片没识别。日志没有输出。jvisualvm 线程都处理wait的状态。
看到代码行，都是自己执行完成后，wait。


案例2:列表页面查询数量不一致。
查询每次返回的列表页数量不一致。使用了一个线程池去操作一个list。add()
0.count之后再执行select，这个间隔 会不会有业务操作呢？
> 时间很短，复现率很高，基本不可能。于是单独用测试账号测试了一下，确实。
1.count没问题，那么说明数据里的数据没问题。
2.应该是取出数据后，对数据进行业务加工的时候，可能导致的问题。
> 应该就是逻辑BUG
3.代码追述的时候，发现在DAO层数据对象转换View层的对象时候，使用了多线程。操作了list。




