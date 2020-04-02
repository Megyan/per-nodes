# Spring源码深度解析

## 从xml到Bean
XmlBeanFactory对DefaultListtableBeanFactory类进行了扩展，主要用于从XML中读取BeanDefinnition。注册和获取bean都是从父类DefaultListtableBeanFactory中获取。

2.想要读取XML，必须要有ResourceLoader。然后通过DocumentLoader将Resoure转换成Document。

3.BeanDefinitionDocumentReader会对Document进行解析。

那么Resource到底是怎么玩的？
4.Spring是通过ClassPathResource`这是Spring的类`读取文件，使用不同handler读取不同的文件。不同的前缀 `file: http: jar:`会对应不同的handler。
> 不同来源的资源都有对应的Resource实现。FileSystemResource ClassPathResource UrlResource

5.那么如何从Document转换成BeanDefinitions呢？
**BeanDefinitionDocumentReader**

## Bean的加载
[初始化单实例bean](https://www.cnblogs.com/takumicx/p/10162811.html)
[lookup-method和replaced-method使用](https://blog.csdn.net/LightOfMiracle/article/details/74988243)
1.获取Bean的时候，如果是单例模式，首先会从缓存中尝试获取

2.只有单例模式且不是在构造方法中进行注入的，才会解决循环依赖
>解决缓存依赖的问题，是不等Bean完全加载完毕，就将Bean曝光加入缓存中。

3.单例的bean的创建。
```
singletonObjects: 保存BeanName和bean实例之间的关系
singletonFactories: 保存BeanName和创建bean的工厂之间的关系.一旦最终对象被创建(通过objectFactory.getObject())，此引用信息将删除

earlySingletonObjects: 保存BeanName和创建bean的关系。用于存储在创建Bean早期对创建的原始bean的一个引用，注意这里是原始bean，即使用工厂方法或构造方法创建出来的对象，一旦对象最终创建好，此引用信息将删除
```
在真实创建单例Bean之前要进行一些准备，
a 检查缓存是否加载过 b 若是没有加载，记录beanName的正在加载的状态 
c 加载单例前记录加载状态 `就是将beanName放入一个Map中，可以检测循环依赖`
>beforeSingletonCreation 方法在每次创建对象之前都会被调用，对于创建同一个 bean 的第二次之后的调用就会触发该方法抛出异常，而我们在前面的例子中通过构造方法注入时，因为创建目标对象需要调用包含依赖对象类型参数的构造方法，而循环依赖势必导致该构造方法的循环调用，从而触发该方法抛出异常。但是对于 setter 注入来说就不存在这样的问题，因为 Spring 对于 bean 实例的构造是分两步走的，第一步完成对象的创建，第二步再执行对象的初始化操作，将相应的属性值注入到该对象中。这个情况下即使有循环依赖也不会阻碍对象的创建，因为这个时候调用的是无参数的构造方法（即使有参数，参数中也不包含循环依赖的对象），所以基于 setter 方法的单例对象循环依赖，容器的初始化机制能够很好的处理
>
d 调用传入的ObjectFactory的Object方法实例化bean
f 加载单例后的处理方法调用 `移除缓存中对该bean的正在加载状态的记录`

3.1 实例化前会进行后置处理器。

4.循环依赖
![](media/15856364139601/15856595712736.jpg)

[三个缓存的关系](https://my.oschina.net/wangzhenchao/blog/1217725)
让A提前暴露ObjectFactory。循环依赖时让ObjectFactory返回一个正在创建的bean。
因为Spring容器不缓存原型prototype类型的bean，所以无法提前暴露一个创建中的Bean

```
首先从一级缓存 singletonObjects 获取，如果没有且当前指定的 beanName 正在创建，就再从二级缓存中 earlySingletonObjects 获取，如果还是没有获取到且运行 singletonFactories 通过 getObject() 获取，则从三级缓存 singletonFactories 获取，如果获取到则，通过其 getObject() 获取对象，并将其加入到二级缓存 earlySingletonObjects 中 从三级缓存 singletonFactories 删除
```

5.实例化Bean
a 实例bean，将BeanDefinition转换成BeanWapper
b MergedBeanDefinitionPostProcessor的应用
c 依赖处理
d 属性填充
e 循环依赖检查
> 对spring不能处理的循环依赖，抛出异常
f 注册DisposableBean 注册destory-method方法

6.实例化策略。根据创建对象情况的不同，提供了三种策略：无参构造方法、有参构造方法、工厂方法。
```
1.选择合适的构造器
核心思想是：如果设置了factory-method属性,则使用工厂方法创建实例,否则根据参数的个数和类型选择构造器进行实例化,这里因为解析构造器比较花时间所以做了
缓存处理,使得整个逻辑变得更加复杂。
2.选择实例化策略实例化对象
选择了合适的构造器后,容器会根据bean的定义中是否存在需要动态改变的方法(lookup-method,replace-method)选择不同的实例化策略:不存在则直接使用反射创建对象;存在则使用cglib生成子类的方式动态的
进行方法替换。
```

7.BeanFactory和ApplicationContext的区别
BeanFactory接口定义的核心容器。比如配置文件的加载解析,Bean依赖的注入以及生命周期的管理。面向Spring框架本身,一般不会被用户直接使用
ApplicationContext接口定义的容器,通常译为应用上下文,称其为应用容器。ApplicationContext本身,则专注于在应用层对BeanFactory作扩展,比如提供对国际化的支持,支持框架级的事件监听机制以及增加了很多对应用环境的适配等。ApplicationContext面向的是使用Spring框架的开发者
[](https://www.cnblogs.com/takumicx/p/9757492.html)

9.BeanDefinition包含了什么？
是否单例`isSingleton`？是否抽象的？是否为自动装配的主要候选bean`isPrimary`
是否赖加载`isLazyInit` 依赖的bean `getDependsOn` 构造函数参数 `bean的构造函数参数`

## BeanPostFactory

```
InstantiationAwareBeanPostProcessor总结
postProcessBeforeInstantiation方法在目标对象实例化之前调用，可以返回一个代理对象来代替目标对象本身；如果返回非null对象，则除了调用postProcessAfterInitialization方法外，其他bean的构造过程都不再调用；
postProcessAfterInstantiation方法在对象实例化之后，属性设置之前调用；如果返回值是true，目标bean的属性会被populate，返回false则忽略populate过程；
postProcessPropertyValues方法在属性被设置到目标实例之前调用，可以修改属性的设置，PropertyValues pvs表示参数值，PropertyDescriptor[] pds表示目标bean 的属性描述信息，返回值PropertyValues，可以用一个全新的PropertyValues来替代原来的pvs，如果返回null，将忽略属性设置过程；
```
1.AOP就是利用`SmartInstantiationAwareBeanPostProcessor`，在创建实例前试图返回一个代理对象。
SmartInstantiationAwareBeanPostProcessor继承了InstantiationAwareBeanPostProcessor

[Spring后置处理器整理](https://juejin.im/post/5da98c54e51d4531a74237cc)
[再谈Spring BeanPostProcessor](https://www.jianshu.com/p/6d7f01bc9def)
[BeanPostProcessor接口总结](https://blog.csdn.net/wang704987562/article/details/80716267)

##BeanFactoryPostProcessor
BeanFactoryPostProcessor简单得说 就是用来操作BeanDefinition。
最简单的使用就是添加自定义的BeanDefinition.
>那么是不是可以这样认为，基于注解加载Bean就会使用这个？去注册BeanDefinition

另外PropertyPlaceholderConfiguer读取properties替换spring.xml中的占位符

```
允许自定义修改应用程序上下文的bean定义，调整上下文的基础bean工厂的bean属性值。应用程序上下文可以在其bean定义中自动检测BeanFactoryPostProcessor bean，并在创建任何其他bean之前先创建BeanFactoryPostProcessor。BeanFactoryPostProcessor可以与bean定义交互并修改bean定义，但绝不能与bean实例交互。这样做可能会导致bean过早实例化，违反容器并导致意外的副作用。如果需要bean实例交互，请考虑实现BeanPostProcessor。实现该接口，可以允许我们的程序获取到BeanFactory，从而修改BeanFactory，可以实现编程式的往Spring容器中添加Bean
```
[BeanFactoryPostProcessor](https://juejin.im/post/5d764527518825676e3a6206)

## 基于注解的Bean加载
那么基于注解的方式Spring是如何加载Bean的？
```
ClassPathXmlApplicationContext在构造时先是setLocations设置路径值（字符串），然后在refresh完成了将路径转化为Resource，并读取Resource成BeanDefinition，还有后面一系列逻辑。而AnnotationConfigApplicationContext在register方法里就将注解转化为了BeanDefinition并注册，refresh里做的事要少一些（符合Generic系的ApplicationContext特征）
```



2.DefaultListableBeanFactory不单继承BeanFactory还继承了BeanFactory。
>BeanDefinitionRegistry 接口定义抽象了Bean的注册逻辑
>BeanFactory及其子类提供了查看Bean的个数，定制类装载器，属性编辑器和按名称后者类型注册的功能

3.AnnotationConfigApplicationContext的创建就是创建DefaultListableBeanFactory。同时加载一些处理器。

4.创建AnnotationConfigApplicationContext过程中会先创建：
读取注解的Bean定义读取器`AnnotatedBeanDefinitionReader` 这个哥们会注册一堆的注解处理器，在各个扩展点对不同注解进行处理。**会预先注册一些BeanPostProcessor和BeanFactoryPostProcessor，这些处理器会在接下来的spring初始化流程中被调用**。
`ClassPathBeanDefinitionScanner`对象会扫描包，继而转换成BeanDefinition。

AnnotatedBeanDefinitionReader会注册**ConfigurationClassPostProcessor**，它是`postProcessBeanDefinitionRegistry()方法内部处理@Configuration，@Import，@ImportResource和类内部的@Bean。`
还会注册**AutowiredAnnotationBeanPostProcessor**，是BeanPostProcessor。
`用来@Autowired注解和@Value注解的`
[AnnotatedBeanDefinitionReader和ClassPathBeanDefinitionScanner的初始化](https://blog.csdn.net/shenmaxiang/article/details/79377236)

5.执行BeanFactoryProces时候会扫描。并将扫描的结果转换成BeanDefinition
>真正被执行的是ConfigurationClassPostProcesor，但它是ConfigurationClassPostProcessor的子类，最终继承BeanFactoryPostProcessor
BeanDefinitionRegistryPostProcessor 同时也是**BeanDefinitionRegistryPostProcessor**的子类，所以才能执行注册动作。

6.ClassPathBeanDefinitionScanner作用就是将指定包下的类通过一定规则过滤后 将Class 信息包装成 BeanDefinition 的形式注册到IOC容器中。
[Spring 的类扫描器分析 - ClassPathBeanDefinitionScanner](https://www.jianshu.com/p/d5ffdccc4f5d)

[重要-基于注解的加载](https://www.haoxiaoyong.cn/2019/12/01/2019/2019-12-01-spring1/)
[Spring中的@Configuration](https://zhuanlan.zhihu.com/p/69139748)
[基于注解的Bean加载过程](https://www.jianshu.com/p/435673fa97a5)
[BeanFactory及其子类](cnblogs.com/siwuxie095/p/6790721.html)
[Spring容器加载Bean定义信息的两员大将：AnnotatedBeanDefinitionReader和ClassPathBeanDefinitionScanner](https://cloud.tencent.com/developer/article/1497799)

## spring容器的启动过程

1.prepareRefresh().做些准备工作。在这个函数内，有个`initPropertySource()`.可以设置需要校验的属性。

2.obtainFreshBeanFactory();执行这个方法之后ApplicationContext才又了BeanFactory的全部功能。**同时也在这里加载BeanDefiniton**

3.prepareBeanFactory() 不知道干啥

4.postProcessBeanFactory()
PropertyPlaceholderCongiuer.用来加载配置文件，去解析spring配置文件中的占位符。



```java
// 读取spring xml配置文件，创建和初始化benas，最核心的方法
public void refresh() throws BeansException, IllegalStateException {
   synchronized (this.startupShutdownMonitor) {
      // 准备工作，设置ApplicationContext中的一些标志位，如closed设为false，active设为true。校验添加了required标志的属性，如果他们为空，则抛出MissingRequiredPropertiesException异常。此处比较简单，可自行分析
      prepareRefresh();

      // 读取spring xml配置文件,后面详细分析
      ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();

      // 设置容器beanFactory的各种成员属性，比如beanClassLoader，beanPostProcessors。这里的beanPostProcessor都是系统默认的，不是用户自定义的。比如负责注入ApplicationContext引用到各种Aware中的ApplicationContextAwareProcessor容器后处理器。
      prepareBeanFactory(beanFactory);

      try {
         // 调用默认的容器后处理器，如ServletContextAwareProcessor
         postProcessBeanFactory(beanFactory);

         // 初始化并调用所有注册的容器后处理器BeanFactoryPostProcessor，此处比较麻烦，但不算关键，可自行分析
         invokeBeanFactoryPostProcessors(beanFactory);

         // 注册bean后处理器，将实现了BeanPostProcessor接口的bean找到。先将实现了PriorityOrdered接口的bean排序并注册到容器BeanFactory中，然后将实现了Ordered接口的排序并注册到容器中，最后注册剩下的。
         registerBeanPostProcessors(beanFactory);

         // 初始化MessageSource，用来处理国际化。如果有beanName为“messageSource”，则初始化。否则使用默认的。
         initMessageSource();

         // 初始化ApplicationEventMulticaster，用来进行事件广播。如果有beanName为"applicationEventMulticaster"，则初始化它。否则使用默认的SimpleApplicationEventMulticaster。广播事件会发送给所有监听器，也就是实现了ApplicationListener的类。关于spring事件体系，可以参见 http://blog.csdn.net/caihaijiang/article/details/7460888
         initApplicationEventMulticaster();

         // 初始化其他特殊的bean。子类可以override这个方法。如WebApplicationContext的themeSource
         onRefresh();

         // 注册事件监听器，也就是所有实现了ApplicationListener的类。会将监听器加入到事件广播器ApplicationEventMulticaster中，所以在广播时就可以发送消息给所有监听器了。
         registerListeners();

         // 初始化所有剩下的singleton bean(没有标注lazy-init的)，后面详细分析
         finishBeanFactoryInitialization(beanFactory);

         // 最后一步，完成refresh。回调LifecycleProcessor，发送ContextRefreshedEvent事件等，比较简单，可自行分析
         finishRefresh();
      }

      catch (BeansException ex) {
         // 异常处理，省略
        ...
      }

      finally {
         // 清理资源
         resetCommonCaches();
      }
   }
}
```



## AOP
1.AnnotationAwareAspectJAutoProxyCreator继承了BeanPostProcessor。在实例化之前，尝试返回代理对象。

2.获取增强器，本质是找到声明AspectJ注解的类。各种通知将会包装成增强器
[Spring AOP增强(Advice)](https://www.jianshu.com/p/6c1b73b54c46)

3.如果目标对象实现了接口，默认情况下会采用JDK的动态代理实现AOP。`当然可以强制使用CGLIB <aop:aspectj-autoproxy proxy-target-class="true">`

4.执行目标方法前 需要执行拦截器链条


