# Log4J learn note

* Log4J的日志级别是有顺序。 all<debug<info<warn<error<fatal<off （是个人就知道了）
* Log4J的Logger是体系结构的。这个层次结构和类的结构是保持一致的。
* Log4J的叁要素

```
Logger：日志记录器

Appender：什么地方

Layout：什么格式

```
* Appender具有追加性，所以同一行日志既能出现到默认的全局日志文件里，也能出现在具体某个类的日志文件中

```
Logger上的Appender不光能继承其父Logger上的Appender，
更重要的是，他不光只继承一个，而是只要是其父Logger，
其上指定的Appender都会追加到这个子Logger之上

```

* Appender的追加性，有时候并不是我们想要的。在Logger上，都有一个setAdditivity方法，
如果设置setAdditivity为false，则该logger的子类停止追加该logger之上的Appender；如果设置为true，则具有追加性

* 博客引用：https://my.oschina.net/xianggao/blog/518059