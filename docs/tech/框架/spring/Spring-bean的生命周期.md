# Spring-bean的生命周期

1.bean的生命周期是?
2.使用@Bean的方式 实现初始化和注销方法(实际上的注销和初始化都是JVM做的,我们添加的都是额外的动作)
2.初始化和销毁有四种方式
3.容器创建对象的时机,单实例是?多实例是?
4.**自定义初始化方法**被容器调用的时机?
4.如果是多实例,容器会创建实例,但是不会负责管理.比如销毁的时候就不会调用自定义的销毁方法
5.**InitializingBean**（定义初始化逻辑）的执行时机与自定义初始化方法一样
6.**DisposableBean** 执行时机与自定义的销毁方法一样
7.基于JSR250规范的**@PostConstruct和@PreDestroy**
8.BeanPostProcessor 后置处理器.在bean初始化前后做一些工作.(这就是勾子)

```java
@Component
public class Car {
	
	public Car(){
		System.out.println("car constructor...");
	}
	
	public void init(){
		System.out.println("car ... init...");
	}
	
	public void detory(){
		System.out.println("car ... detory...");
	}

}


@ComponentScan("com.atguigu.bean")
@Configuration
public class MainConfigOfLifeCycle {
	
	//@Scope("prototype")
	@Bean(initMethod="init",destroyMethod="detory")
	public Car car(){
		return new Car();
	}

}

```


```java
/**
 * bean的生命周期：
 * 		bean创建---初始化----销毁的过程
 * 容器管理bean的生命周期；
 * 我们可以自定义初始化和销毁方法；容器在bean进行到当前生命周期的时候来调用我们自定义的初始化和销毁方法
 * 
 * 构造（对象创建）
 * 		单实例：在容器启动的时候创建对象
 * 		多实例：在每次获取的时候创建对象\
 * 
 * BeanPostProcessor.postProcessBeforeInitialization
 * 初始化：
 * 		对象创建完成，并赋值好，调用初始化方法。。。
 * BeanPostProcessor.postProcessAfterInitialization
 * 销毁：
 * 		单实例：容器关闭的时候
 * 		多实例：容器不会管理这个bean；容器不会调用销毁方法；
 * 
 * 
 * 遍历得到容器中所有的BeanPostProcessor；挨个执行beforeInitialization，
 * 一但返回null，跳出for循环，不会执行后面的BeanPostProcessor.postProcessorsBeforeInitialization
 * 
 * BeanPostProcessor原理
 * populateBean(beanName, mbd, instanceWrapper);给bean进行属性赋值
 * initializeBean
 * {
 * applyBeanPostProcessorsBeforeInitialization(wrappedBean, beanName);
 * invokeInitMethods(beanName, wrappedBean, mbd);执行自定义初始化
 * applyBeanPostProcessorsAfterInitialization(wrappedBean, beanName);
 *}
 * 
 * 
 * 
 * 1）、指定初始化和销毁方法；
 * 		通过@Bean指定init-method和destroy-method；
 * 2）、通过让Bean实现InitializingBean（定义初始化逻辑），
 * 				DisposableBean（定义销毁逻辑）;
 * 3）、可以使用JSR250；
 * 		@PostConstruct：在bean创建完成并且属性赋值完成；来执行初始化方法
 * 		@PreDestroy：在容器销毁bean之前通知我们进行清理工作
 * 4）、BeanPostProcessor【interface】：bean的后置处理器；
 * 		在bean初始化前后进行一些处理工作；
 * 		postProcessBeforeInitialization:在初始化之前工作
 * 		postProcessAfterInitialization:在初始化之后工作
 * 
 * Spring底层对 BeanPostProcessor 的使用；
 * 		bean赋值，注入其他组件，@Autowired，生命周期注解功能，@Async,xxx BeanPostProcessor;
 * 
 * @author lfy
 *
 */
@ComponentScan("com.atguigu.bean")
@Configuration
public class MainConfigOfLifeCycle {
	
	//@Scope("prototype")
	@Bean(initMethod="init",destroyMethod="detory")
	public Car car(){
		return new Car();
	}

}

```

## BeanPostProcessor的工作原理

1.创建容器 		
ApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);

2.刷新容器 也就是上一步new中调用了refresh()

3.refesh() 中调用了 finishBeanFactoryInitialization()初始化所有单实例的对象

4.finishBeanFactoryInitialization() -> preInstantiateSingletons() -> getBean

5.getBean() -> doGetBean() -> getSingleton() ->

6.pupulateBean() 为属性赋值

7.instantiateBean() 

8.invokeInitMethods() 执行初始化方法

## 常见的BeanPostProcessor实现

1.ApplicationContextAware 负责注入容器上下文 ApplicationContextAwareProcessor负责处理.
ApplicationContextAwareProcessor是BeanPostProcessor的一个实现

2.BeanPostProcessorChecker bean的校验 同样是BeanPostProcessor的一个实现

3.InitDestroyAnnotationBeanPostProcessor 负责@PostConstruct @PreDestroy

4.AutowiredAnnotationBeanPostProcessor 负责@Autowired @Inject

总结下功能点:bean赋值，注入其他组件，@Autowired，生命周期注解功能，@Async,xxx 


