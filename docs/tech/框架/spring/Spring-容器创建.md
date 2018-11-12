# Spring-容器创建

refresh()

## 1.prepareRefresh()
刷新前的预处理

1）、initPropertySources()初始化一些属性设置;子类自定义个性化的属性设置方法；
`AbstractApplicationContext
我们自己可以写AbstractApplicationContext的子类实现,initPropertySources()就是初始化子类中自定义属性的内容`

2）、getEnvironment().validateRequiredProperties();检验属性的合法等

3）、earlyApplicationEvents= new LinkedHashSet<ApplicationEvent>();
  创建了一个容器,用于保存一些早期的事件；

## 2.obtainFreshBeanFactory()
获取BeanFactory

1）、refreshBeanFactory();刷新【创建】BeanFactory；
	创建了一个this.beanFactory = new DefaultListableBeanFactory();
	设置id；
2）、getBeanFactory();返回刚才GenericApplicationContext创建的BeanFactory对象；
3）、将创建的BeanFactory【DefaultListableBeanFactory】返回；

## 3.prepareBeanFactory(beanFactory)
上一步创建了BeanFactory,并做了一些默认值的处理.
BeanFactory的预准备工作（BeanFactory进行一些设置）

1）、设置BeanFactory的类加载器、支持表达式解析器...

2）、添加部分BeanPostProcessor【ApplicationContextAwareProcessor】

3）、设置忽略的自动装配的接口EnvironmentAware、EmbeddedValueResolverAware、xxx；
   `上述这些类,不能在自定义bean中自动注入`
   
4）、注册可以解析的自动装配；我们能直接在任何组件中自动注入：
		BeanFactory、ResourceLoader、ApplicationEventPublisher、ApplicationContext
		
5）、添加BeanPostProcessor【ApplicationListenerDetector】

6）、添加编译时的AspectJ；
7）、给BeanFactory中注册一些能用的组件；
	environment【ConfigurableEnvironment】、
	systemProperties【Map<String, Object>】、
	systemEnvironment【Map<String, Object>】
	
	
## 4.postProcessBeanFactory(beanFactory)
BeanFactory准备工作完成后进行的后置处理工作；

1）、子类通过重写这个方法来在BeanFactory创建并预准备完成以后做进一步的设置

`本质是留了一个钩子,允许方法的实现者在beanFactory创建完毕后,去做一些自定义的事情`
==================**以上是BeanFactory的创建及预准备工作**=======================

## 5.invokeBeanFactoryPostProcessors(beanFactory)
执行BeanFactoryPostProcessor的方法；

BeanFactoryPostProcessor：BeanFactory的后置处理器。在BeanFactory标准初始化之后执行的；
`标准初始化就是前边的四步`

BeanFactoryPostProcessor 有两类重要的实现,一类是BeanFactoryPostProcessor直接实现,一类是BeanDefinitionRegistryPostProcessor的实现

先执行BeanDefinitionRegistryPostProcessor
1）、获取所有的BeanDefinitionRegistryPostProcessor；
2）、看先执行实现了PriorityOrdered优先级接口的BeanDefinitionRegistryPostProcessor、
	postProcessor.postProcessBeanDefinitionRegistry(registry)
3）、在执行实现了Ordered顺序接口的BeanDefinitionRegistryPostProcessor；
	postProcessor.postProcessBeanDefinitionRegistry(registry)
4）、最后执行没有实现任何优先级或者是顺序接口的BeanDefinitionRegistryPostProcessors；
	postProcessor.postProcessBeanDefinitionRegistry(registry)
	
	
再执行BeanFactoryPostProcessor的方法
1）、获取所有的BeanFactoryPostProcessor
2）、看先执行实现了PriorityOrdered优先级接口的BeanFactoryPostProcessor、
	postProcessor.postProcessBeanFactory()
3）、在执行实现了Ordered顺序接口的BeanFactoryPostProcessor；
	postProcessor.postProcessBeanFactory()
4）、最后执行没有实现任何优先级或者是顺序接口的BeanFactoryPostProcessor；
	postProcessor.postProcessBeanFactory()

			postProcessor.postProcessBeanFactory()
## 6.registerBeanPostProcessors(beanFactory)
注册BeanPostProcessor（Bean的后置处理器）【 intercept bean creation】

不同接口类型的BeanPostProcessor；在Bean创建前后的执行时机是不一样的
BeanPostProcessor、
DestructionAwareBeanPostProcessor、
InstantiationAwareBeanPostProcessor、
SmartInstantiationAwareBeanPostProcessor、
MergedBeanDefinitionPostProcessor【internalPostProcessors】、
		
1）、获取所有的 BeanPostProcessor;后置处理器都默认可以通过PriorityOrdered、Ordered接口来执行优先级
2）、先注册PriorityOrdered优先级接口的BeanPostProcessor；
	把每一个BeanPostProcessor；添加到BeanFactory中
	beanFactory.addBeanPostProcessor(postProcessor);
3）、再注册Ordered接口的
4）、最后注册没有实现任何优先级接口的
5）、最终注册MergedBeanDefinitionPostProcessor；
6）、注册一个ApplicationListenerDetector；来在Bean创建完成后检查是否是ApplicationListener，如果是
	applicationContext.addApplicationListener((ApplicationListener<?>) bean);


