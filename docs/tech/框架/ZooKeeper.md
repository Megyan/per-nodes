ZooKeeper
## ZK的能力
ZooKeeper 是一个典型的分布式数据一致性解决方案，分布式应用程序可以基于 ZooKeeper 实现诸如数据发布/订阅、负载均衡、命名服务、分布式协调/通知、集群管理、Master 选举、分布式锁和分布式队列等功能。
Zookeeper 一个最常用的使用场景就是用于担任服务生产者和服务消费者的注册中心。Dubbo就推荐使用Zookeeper作为服务注册中心

## ZK的概念
ZooKeeper 底层其实只提供了两个功能：
①管理（存储、读取）用户程序提交的数据；②为用户程序提交数据节点监听服务

**基本概念：**

* 高可用（分布式，半数节点存活，就可以正常服务）
* 高吞吐量和低延迟（数据常驻内存）
* 高性能 读性能高于写（因为写会导致所有服务器更新状态）
* 临时节点 会话终结后，节点被移除

**会话Session**

* TCP长链接
* Timeout内与ZK集群内任意节点保持连接，会话都不会失效
* sessionID全局唯一

**Znode**

* “节点"分为两类，第一类同样是指构成集群的机器，我们称之为机器节点；第二类则是指数据模型中的数据单元，我们称之为数据节点一一ZNode
* node可以分为持久节点和临时节点两类

**版本**

* 版本 ZK维护一个叫作 Stat 的数据结构，Stat中记录了这个 ZNode 的三个数据版本，分别是version（当前ZNode的版本）、cversion（当前ZNode子节点的版本）和 cversion（当前ZNode的ACL版本）

**Watcher 重要**

Watcher（事件监听器），是Zookeeper中的一个很重要的特性。Zookeeper允许用户在指定节点上注册一些Watcher，并且在一些特定事件触发的时候，ZooKeeper服务端会将事件通知到感兴趣的客户端上去，该机制是Zookeeper实现分布式协调服务的重要特性

**ACL**
采用ACL（AccessControlLists）策略来进行权限控制。

* CREATE：创建子节点
* READ：获取节点数据和子节点列表
* WRITE：更新节点数据的权限
* DELETE：删除子节点的权限
* ADMIN：设置节点的ACL权限

## ZK的特点
* **顺序一致性：** 从同一客户端发起的事务请求，最终将会严格地按照顺序被应用到 ZooKeeper 中去
* **原子性：** 所有事务请求的处理结果在整个集群中所有机器上的应用情况是一致的，也就是说，要么整个集群中所有的机器都成功应用了某一个事务，要么都没有应用
* **单一系统映像 ：** 无论客户端连到哪一个 ZooKeeper 服务器上，其看到的服务端数据模型都是一致的
* **可靠性：** 一旦一次更改请求被应用，更改的结果就会被持久化，直到被下一次更改覆盖

## ZK的集群角色
在 ZooKeeper 中没有选择传统的  Master/Slave 概念，而是引入了Leader、Follower 和 Observer 三种角色

* Leader 既可以为客户端提供写服务又能提供读服务
* Follower 和  Observer 都只能提供读服务
* Follower 和  Observer 唯一的区别在于 Observer 机器不参与 Leader 的选举过程，也不参与写操作的“过半写成功”策略


**参考**
<https://juejin.im/post/5b970f1c5188255c865e00e7?utm_source=gold_browser_extension>

<http://blog.xiaohansong.com/2016/09/30/Paxos/>

《从Paxos到Zookeeper 》


