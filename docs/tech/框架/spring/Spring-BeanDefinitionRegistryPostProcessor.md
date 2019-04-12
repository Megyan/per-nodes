# Spring-BeanDefinitionRegistryPostProcessor

1.BeanFactoryPostProcessor的子接口.

2.**postProcessBeanDefinitionRegistry()**;
在所有bean定义信息将要被加载，bean实例还未创建的；

3.优先于`BeanFactoryPostProcessor`执行；

4.可以利用`BeanDefinitionRegistryPostProcessor`给容器中再额外添加一些组件；

## 原理
基本同BeanFactoryPostProcessor.

首先利用beanFactory获取到所有BeanDefinitionRegistryPostProcessor的名称

```java
postProcessorNames = beanFactory.getBeanNamesForType(
    BeanDefinitionRegistryPostProcessor.class
    , true
    , false);
```

然后获取到实例对象,并且执行

```java
beanFactory.getBean(ppName, BeanDefinitionRegistryPostProcessor.class)
//上一步获得bean 被add到currentRegistryProcessors中.
//执行
invokeBeanDefinitionRegistryPostProcessors(currentRegistryProcessors, registry);

```


1）、ioc创建对象

2）、refresh()-> invokeBeanFactoryPostProcessors(beanFactory);

3）、从容器中获取到所有的BeanDefinitionRegistryPostProcessor组件。

```
1、依次触发所有的postProcessBeanDefinitionRegistry()方法
2、再来触发postProcessBeanFactory()方法BeanFactoryPostProcessor；
```

4）、再来从容器中找到BeanFactoryPostProcessor组件；然后依次触发postProcessBeanFactory()方法


```java
public class MyBeanDefinitionRegistryPostProcessor implements BeanDefinitionRegistryPostProcessor{

	@Override
	public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {
		// TODO Auto-generated method stub
		System.out.println("MyBeanDefinitionRegistryPostProcessor...bean的数量："+beanFactory.getBeanDefinitionCount());
	}

	//BeanDefinitionRegistry Bean定义信息的保存中心，以后BeanFactory就是按照BeanDefinitionRegistry里面保存的每一个bean定义信息创建bean实例；
	@Override
	public void postProcessBeanDefinitionRegistry(BeanDefinitionRegistry registry) throws BeansException {
		// TODO Auto-generated method stub
		System.out.println("postProcessBeanDefinitionRegistry...bean的数量："+registry.getBeanDefinitionCount());
		//RootBeanDefinition beanDefinition = new RootBeanDefinition(Blue.class);
		AbstractBeanDefinition beanDefinition = BeanDefinitionBuilder.rootBeanDefinition(Blue.class).getBeanDefinition();
		registry.registerBeanDefinition("hello", beanDefinition);
	}

}
```

