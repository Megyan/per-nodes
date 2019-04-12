# Spring-ApplicationListener

## 简介及应用
ApplicationListener：监听容器中发布的事件。事件驱动模型开发；

```java
	//监听 ApplicationEvent 及其下面的子事件；
  public interface ApplicationListener<E extends ApplicationEvent>
```
**使用步骤**

1）、写一个监听器（ApplicationListener实现类）来监听某个事件（ApplicationEvent及其子类）

或者使用@EventListener;
原理：使用EventListenerMethodProcessor处理器来解析方法上的@EventListener；

2）、把监听器加入到容器；

3）、只要容器中有相关事件的发布，我们就能监听到这个事件；

```
	ContextRefreshedEvent：容器刷新完成（所有bean都完全创建）会发布这个事件；
	ContextClosedEvent：关闭容器会发布这个事件；
```
		
4）、发布一个事件：
		`applicationContext.publishEvent()；`

```java
@Component
public class MyApplicationListener implements ApplicationListener<ApplicationEvent> {

	//当容器中发布此事件以后，方法触发
	@Override
	public void onApplicationEvent(ApplicationEvent event) {
		// TODO Auto-generated method stub
		System.out.println("收到事件："+event);
	}

}
```
## 原理

### 事件发布流程

1）、容器创建对象：`AnnotationConfigApplicationContext#refresh()`；

2）、`AbstractApplicationContext#finishRefresh()`;容器刷新完成会发布ContextRefreshedEvent事件

3）、`publishEvent(new ContextRefreshedEvent(this))`;发布事件；如何派发事件呢？
 
  a 获取事件的多播器（派发器）：getApplicationEventMulticaster()
  
  b multicastEvent()派发事件：
  
```java
		for (final ApplicationListener<?> listener : getApplicationListeners(event, type)) {
		1）、如果有Executor，可以支持使用Executor进行异步派发；
			Executor executor = getTaskExecutor();
		2）、否则，同步的方式直接执行listener方法；invokeListener(listener, event);
		 拿到listener回调onApplicationEvent方法；
		 }
```

## 事件多播器（派发器）创建过程

广播的关键在于<span style="color:#f00">getApplicationEventMulticaster()</span>多播器的获取.那这个多播器究竟是怎么获取的呢?`SimpleApplicationEventMulticaster`多播器是用来发布事件的

1）、容器创建对象：refresh()

2）、initApplicationEventMulticaster();初始化ApplicationEventMulticaster；

```
1）、先去容器中找有没有id=“applicationEventMulticaster”的组件；
2）、如果没有this.applicationEventMulticaster = new SimpleApplicationEventMulticaster(beanFactory);
```
并且加入到容器中，我们就可以在其他组件要派发事件，自动注入这个applicationEventMulticaster；


### 容器中有哪些监听器

多播器/事件派发器的责任是调用所有监听器,将事件传递给他们,那多播器是如何获取到所有的监听器呢?

1）、容器创建对象：refresh();
2）、registerListeners();
	从容器中拿到所有的监听器，把他们注册到applicationEventMulticaster中；
	
```java
	String[] listenerBeanNames = getBeanNamesForType(ApplicationListener.class, true, false);
	//将listener注册到ApplicationEventMulticaster中
	getApplicationEventMulticaster().addApplicationListenerBean(listenerBeanName);
```		

## SmartInitializingSingleton
	
**SmartInitializingSingleton** 是在所有单实例bean都实例化后才会执行的,类似于发布了`ContextRefreshedEvent`.但是关注这个事件的对象无需实现ApplicationListener.
也就是说,如果你关系实例创建完毕,但是又不想监听ContextRefreshedEvent.你可以使用**SmartInitializingSingleton**

@EventListener的处理器`EventListenerMethodProcessor`就是**SmartInitializingSingleton**

SmartInitializingSingleton 原理：->afterSingletonsInstantiated();

```
1）、ioc容器创建对象并refresh()；
2）、finishBeanFactoryInitialization(beanFactory);初始化剩下的单实例bean；
	1）、先创建所有的单实例bean；getBean();
	2）、获取所有创建好的单实例bean，判断是否是SmartInitializingSingleton类型的；
		如果是就调用afterSingletonsInstantiated();
```

```java
if (singletonInstance instanceof SmartInitializingSingleton) {
    //....
    smartSingleton.afterSingletonsInstantiated();
}
```
	

