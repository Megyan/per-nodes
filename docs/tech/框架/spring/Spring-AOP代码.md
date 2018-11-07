# AOP 代码流程


### 创建后置处理器的过程

创建BeanPostProcessor的过程 上述第六步的细节.
以创建internalAutoProxyCreator的BeanPostProcessor【AnnotationAwareAspectJAutoProxyCreator】为例子
	
```				
1）、创建Bean的实例
2）、populateBean；给bean的各种属性赋值
3）、initializeBean：初始化bean；
		1）、invokeAwareMethods()：处理Aware接口的方法回调
		2）、applyBeanPostProcessorsBeforeInitialization()：应用后置处理器的postProcessBeforeInitialization（）
		3）、invokeInitMethods()；执行自定义的初始化方法
		4）、applyBeanPostProcessorsAfterInitialization()；执行后置处理器的postProcessAfterInitialization（）；
4）、BeanPostProcessor(AnnotationAwareAspectJAutoProxyCreator)创建成功；
-->aspectJAdvisorsBuilder 
这里就是继承AbstractAutoProxyCreator使用setBeanFactory()

```	
===========以上是创建和注册AnnotationAwareAspectJAutoProxyCreator的过程========
AnnotationAwareAspectJAutoProxyCreator 的父类是 InstantiationAwareBeanPostProcessor

>实际上也是普通Bean的创建过程?
>遗留几个问题:
>1.BeanFactory 有什么用?
>2.AnnotationAwareAspectJAutoProxyCreator 之所以实现AbstractAutoProxyCreator有什么用?


### 创建普通单实例Bean的过程

1）、遍历获取容器中所有的Bean，依次创建对象getBean(beanName);
	getBean->doGetBean()->getSingleton()
	
2）、创建bean
	
	1）、先从缓存中获取当前bean，如果能获取到，说明bean是之前被创建过的，直接使用，否则再创建；
		只要创建好的Bean都会被缓存起来
		
	2）、createBean（）;创建bean；
	
具体createBean()里面的逻辑如下:

``` 
1）、后置处理器先尝试返回对象；
    resolveBeforeInstantiation(beanName, mbdToUse);
    解析BeforeInstantiation,希望后置处理器在此能返回一个代理对象；
    如果能返回代理对象就使用，如果不能就继续
    {
    	bean = applyBeanPostProcessorsBeforeInstantiation（）：
    		拿到所有后置处理器，如果是InstantiationAwareBeanPostProcessor;
    		就执行postProcessBeforeInstantiation
    	if (bean != null) {
    	bean = applyBeanPostProcessorsAfterInitialization(bean, beanName);
    }
    //这段代码体现了,即使是代理对象也需要应用Before和After的处理器

2）、doCreateBean(beanName, mbdToUse, args);真正的去创建一个bean实例；和3.6流程一样；
     //doCreateBean 内容同样也应用了Before和After的处理器
```	

为什么创建简单Bean的时候会调用后置处理方法,就是因为有这些后置处理器

AnnotationAwareAspectJAutoProxyCreator 会在任何bean创建之前先尝试返回bean的实例
AnnotationAwareAspectJAutoProxyCreator在所有bean创建之前会有一个拦截，InstantiationAwareBeanPostProcessor，会调用postProcessBoreInstantiation()

```
两类处理器及处理器的时机
【BeanPostProcessor是在Bean对象创建完成初始化前后调用的】
【InstantiationAwareBeanPostProcessor是在创建Bean实例之前先尝试用后置处理器返回对象的】
AnnotationAwareAspectJAutoProxyCreator 就是 InstantiationAwareBeanPostProcessor这类的处理器
```


