# 并发-Lock
## Lock接口

synchronized属于隐式锁，即锁的持有与释放都是隐式的
`那么synchronized是怎么释放的呢?`
Lock接口提供了lock()方法和unLock()方法对显式加锁和显式释放锁操作进行支持

```java
Lock lock = new ReentrantLock();
lock.lock();
try{
    //临界区......
}finally{
    lock.unlock();
}
```

**Lock对象锁与synchronized相比的新特性**

* 1.可中断锁的获取(synchronized在等待获取锁时是不可中的)，
* 2.超时中断锁的获取，
* 3.等待唤醒机制的多条件变量Condition

```java
public interface Lock {
    //加锁
    void lock();

    //解锁
    void unlock();

    //可中断获取锁，与lock()不同之处在于可响应中断操作，即在获
    //取锁的过程中可中断，注意synchronized在获取锁时是不可中断的
    void lockInterruptibly() throws InterruptedException;

    //尝试非阻塞获取锁，调用该方法后立即返回结果，如果能够获取则返回true，否则返回false
    boolean tryLock();

    //根据传入的时间段获取锁，在指定时间内没有获取锁则返回false，如果在指定时间内当前线程未被中并断获取到锁则返回true
    boolean tryLock(long time, TimeUnit unit) throws InterruptedException;

    //获取等待通知组件，该组件与当前锁绑定，当前线程只有获得了锁
    //才能调用该组件的wait()方法，而调用后，当前线程将释放锁。
    Condition newCondition();

}
```

## 重入锁ReetrantLock

**重入**
重入锁ReetrantLock,作用与synchronized关键字相当，但比synchronized更加灵活.
`synchronized也是重入锁`

**公平**
支持公平锁与非公平锁。所谓的公平与非公平指的是在请求先后顺序上，先对锁进行请求的就一定先获取到锁，那么这就是公平锁，反之，如果对于锁的获取并没有时间上的先后顺序，如后请求的线程可能先获取到锁，这就是非公平锁



## AQS


**参考**
<https://blog.csdn.net/javazejian/article/details/75043422>

```
笔记不是单纯重复 复制黏贴,而是理解消化.变成自己的体系.
以下有几个问题:
1.就什么线程不安全?
本质是多个线程对同一内存区域进行了操作,这个操作并不是原子的(参考32位系统的long的加减/JMM 工作内
存和主内容/) 或者线程间并不是有序的.从而某些线程操作的内容有异(明明应该是对10+1,却变成了对
11+1),导致了程序运算结果和预期不符.

2.怎么解决不安全?
操作是有序的,一个一个的来(volatile保证可见性还是会有问题,你看到的时候是10 等你操作的时候可能已
经是11了).
想要有序,就涉及到锁.Lock或者synchronized.
涉及到锁,就涉及性能问题,并发是就是为了提高效率而生,而锁又给这种高效添加了限制.所以各种锁优化(偏向锁/轻量锁/锁自旋/锁粗化/CAS)
```


