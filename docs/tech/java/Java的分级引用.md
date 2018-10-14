# Java的分级引用

```
Q1:强弱虚引用都是如何被创建的?
Q2:各自的应用场景
Q3
```

Java中是JVM负责内存的分配和回收，这是它的优点（使用方便，程序不用再像使用C语言那样担心内存），但同时也是它的缺点（不够灵活）。由此，Java提供了引用分级模型，可以定义**Java对象重要性和优先级，提高JVM内存回收的执行效率**

**引用分类**
强引用(Strong Reference)、软引用(Soft Reference)、弱引用(Weak Reference)、虚引用(Phantom Reference)四种


软引用对象和弱引用对象主要用于：当内存空间还足够，则能保存在内存之中；如果内存空间在垃圾收集之后还是非常紧张，则可以抛弃这些对象。很多系统的缓存功能都符合这样的使用场景。

> 软饮用和弱引用的区别是,对于软饮用 JVM还尝试着保留该引用,只有在OOM之前才会进行清除.
> 而对于弱引用一旦 JVM发生垃圾回收,弱引用就会被回收


而虚引用对象用于替代不靠谱的finalize方法，可以获取对象的回收事件，来做资源清理工作


## 强引用

```java
Object obj = new Object();
String str = "hello world";
```
实际使用上，可以通过把引用显示赋值为null来中断对象与强引用之前的关联，如果没有任何引用执行对象，垃圾收集器将在合适的时间回收对象

> 引用和垃圾回收的关系是? 在实际编程中,java中大量的对象对应很多个引用,在不同的类里被使用.垃圾回收是指,当JVM堆内真实的对象没有对应的引用时就会被回收.

感受下引用

```java
    /**
     * 正确使用引用对象demo
     */
    private static void trueUseRefObjDemo(){
        List<String> myList = new ArrayList<>();
        SoftReference<List<String>> refObj = new SoftReference<>(myList);

        // 正确的使用，使用强引用指向对象保证获得对象之后不会被回收
        List<String> list = refObj.get();
        if (null != list) {
            list.add("hello");
        } else {
            // 整个列表已经被垃圾回收了，做其他处理
        }
    }

    /**
     * 错误使用引用对象demo
     */
    private static void falseUseRefObjDemo(){
        List<String> myList = new ArrayList<>();
        SoftReference<List<String>> refObj = new SoftReference<>(myList);

        // XXX 错误的使用，在检查对象非空到使用对象期间，对象可能已经被回收
        // 可能出现空指针异常
        if (null != refObj.get()) {
            refObj.get().add("hello");
        }
    }

```

需要说明的几点(软引用和弱引用的使用):

* 1、必须经常检查引用值是否为null 垃圾收集器可能随时回收引用对象，如果轻率地使用引用值，迟早会得      到一个NullPointerException。
* 2、必须使用强引用来指向引用对象返回的值 垃圾收集器可能在任何时间回收引用对象，即使在一个表达式中间。
* 3、必须持有引用对象的强引用 如果创建引用对象，没有持有对象的强引用，那么引用对象本身将被垃圾收集器回收。
* 4、当引用值没有被其他强引用指向时，软引用、弱引用和虚引用才会发挥作用，引用对象的存在就是为了方便追踪并高效垃圾回收。

## 软引用和弱引用

软引用

弱引用

```java
    /**
     * 简单使用弱引用demo
     */
    private static void simpleUseWeakRefDemo(){
        WeakReference<String> sr = new WeakReference<>(new String("hello world " ));
        // before gc -> hello world 
        System.out.println("before gc -> " + sr.get());

        // 通知JVM的gc进行垃圾回收
        System.gc();
        // after gc -> null
        System.out.println("after gc -> " + sr.get());
    }

```

但是,如果将上述sr的创建方式改为

```
WeakReference<String> sr = new WeakReference<>("hello world "); 
```
那么结果将是:

```
before gc -> hello world 
after gc -> hello world 
```

这是因为使用Java的String直接赋值和使用new区别在于：

* new 会在堆区创建一个可以被正常回收的对象。
* String直接赋值，例如：String  str = String( "Hello");
JVM首先在string池内里面看找不找到字符串 "Hello"，找到，不做任何事情；
否则，创建新的String对象，放到String常量池里面(常量池Hotspot1.7之前存于永生代，Hotspot1.7和1.7之后的版本存于堆区，通常不会被gc回收)。同时，由于遇到了new，还会在内存上（不是String常量池里面）创建String对象存储 "Hello"，并将内存上的（不是String池内的）String对象返回给str。


WeakHashMap 为了更方便使用弱引用，Java还提供了WeakHashMap，功能类似HashMap，内部实现是用弱引用对key进行包装，当某个key对象没有任何强引用指向，gc会自动回收key和value对象

```java
    /**
     *  weakHashMap使用demo
     */
    private static void weakHashMapDemo(){
        WeakHashMap<String,String> weakHashMap = new WeakHashMap<>();
        String key1 = new String("key1");
        String key2 = new String("key2");
        String key3 = new String("key3");
        weakHashMap.put(key1, "value1");
        weakHashMap.put(key2, "value2");
        weakHashMap.put(key3, "value3");

        // 使没有任何强引用指向key1
        key1 = null;

        System.out.println("before gc weakHashMap = " + weakHashMap + " , size=" + weakHashMap.size());

        // 通知JVM的gc进行垃圾回收
        System.gc();
        System.out.println("after gc weakHashMap = " + weakHashMap + " , size="+ weakHashMap.size());
    }

```

```java
before: gc weakHashMap = {key1=value1, key2=value2, key3=value3} , size=3
after: gc weakHashMap = {key2=value2, key3=value3} , size=2
```

WeakHashMap比较适用于缓存的场景，例如Tomcat的缓存就用到。


## 虚引用


虚引用的主要作用是用于监控对象是否被GC.
虚引用创建的同时需要创建一个引用队列,当时虚引用被GC,那么该引用就会传入该队列内.
我们只需要轮询该队列就可以知道对应的虚引用有没有被GC

* 虚引用不用于访问引用对象所指示的对象，
* 通过不断轮询虚引用对象关联的引用队列，可以得到对象回收事件

引用队列Demo

```java
    /**
     * 引用队列demo
     */
    private static void refQueueDemo() {
        ReferenceQueue<String> refQueue = new ReferenceQueue<>();

        // 用于检查引用队列中的引用值被回收
        Thread checkRefQueueThread = new Thread(() -> {
            while (true) {
                Reference<? extends String> clearRef = refQueue.poll();
                if (null != clearRef) {
                    System.out
                            .println("引用对象被回收, ref = " + clearRef + ", value = " + clearRef.get());
                }
            }
        });
        checkRefQueueThread.start();

        WeakReference<String> weakRef1 = new WeakReference<>(new String("value1"), refQueue);
        WeakReference<String> weakRef2 = new WeakReference<>(new String("value2"), refQueue);
        WeakReference<String> weakRef3 = new WeakReference<>(new String("value3"), refQueue);

        System.out.println("ref1 value = " + weakRef1.get() + ", ref2 value = " + weakRef2.get()
                + ", ref3 value = " + weakRef3.get());

        System.out.println("开始通知JVM的gc进行垃圾回收");
        // 通知JVM的gc进行垃圾回收
        System.gc();
    }

```
结果

```java
ref1 value = value1, ref2 value = value2, ref3 value = value3
开始通知JVM的gc进行垃圾回收
引用对象被回收, ref = java.lang.ref.WeakReference@48c6cd96, value=null
引用对象被回收, ref = java.lang.ref.WeakReference@46013afe, value=null
引用对象被回收, ref = java.lang.ref.WeakReference@423ea6e6, value=null

```

```java
    /**
     * 简单使用虚引用demo
     * 虚引用在实现一个对象被回收之前必须做清理操作是很有用的,比finalize()方法更灵活
     */
    private static void simpleUsePhantomRefDemo() throws InterruptedException {
        Object obj = new Object();
        ReferenceQueue<Object> refQueue = new ReferenceQueue<>();
        PhantomReference<Object> phantomRef = new PhantomReference<>(obj, refQueue);

        // null
        System.out.println(phantomRef.get());
        // null
        System.out.println(refQueue.poll());

        obj = null;
        // 通知JVM的gc进行垃圾回收
        System.gc();

        // null, 调用phantomRef.get()不管在什么情况下会一直返回null
        System.out.println(phantomRef.get());

        // 当GC发现了虚引用，GC会将phantomRef插入进我们之前创建时传入的refQueue队列
        // 注意，此时phantomRef对象，并没有被GC回收，在我们显式地调用refQueue.poll返回phantomRef之后
        // 当GC第二次发现虚引用，而此时JVM将phantomRef插入到refQueue会插入失败，此时GC才会对phantomRef对象进行回收
        Thread.sleep(200);
        Reference<?> pollObj = refQueue.poll();
        // java.lang.ref.PhantomReference@1540e19d
        System.out.println(pollObj);
        if (null != pollObj) {
            // 进行资源回收的操作
        }
    }

```
比较常见的，可以基于虚引用实现JDBC连接池，锁的释放等场景。
以连接池为例，调用方正常情况下使用完连接，需要把连接释放回池中，但是不可避免有可能程序有bug，造成连接没有正常释放回池中。基于虚引用对Connection对象进行包装，并关联引用队列，就可以通过轮询引用队列检查哪些连接对象已经被GC回收，释放相关连接资源




## 总结

|引用类型|	GC回收时间|	 常见用途|生存时间|
| --- | --- | --- |---|
|强引用|	永不|	对象的一般状态	|JVM停止运行时|
|软引用|	内存不足时|	对象缓存|	内存不足时终止|
|弱引用|	GC时|	对象缓存|	GC后终止|

虚引用，配合引用队列使用，通过不断轮询引用队列获取对象回收事件。

**[参考]**
<https://juejin.im/post/5bbfee46e51d450e5e0cba2f?utm_source=gold_browser_extension>


