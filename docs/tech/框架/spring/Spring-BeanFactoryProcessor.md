# BeanFactoryPostProcesser 原理

## 概述

BeanPostProcessor：**bean后置处理器**，bean创建对象初始化前后进行拦截工作的.

BeanFactoryPostProcessor：**beanFactory的后置处理器**；

**作用:**
在BeanFactory标准初始化之后调用，来定制和修改BeanFactory的内容；
	
**执行时机:**
所有的bean定义已经保存加载到beanFactory，但是bean的实例还未创建.

BeanFactory是顶级接口,有三个子接口:
HierarchicalBeanFactory,最终由ApplicationContext及其子类负责实现
`很明显,这个实现的分支跟我们自定义的bean无关`
AutowireCapableBeanFactory,最终由DefaultListableBeanFactory负责实现
ListableBeanFactory,最终由DefaultListableBeanFactory负责实现.

后续两个分支最终都由**DefaultListableBeanFactory**实现,
就是说这个哥们负责了常规的bean`自定义bean及Spring自身的处理器bean`处理.
所以BeanFactoryPostProcessor实际上就是对DefaultListableBeanFactory的后置处理.


## 原理

1)、ioc容器创建对象

2)、invokeBeanFactoryPostProcessors(beanFactory);

```
	如何找到所有的BeanFactoryPostProcessor并执行他们的方法；
	1）、直接在BeanFactory中找到所有类型是BeanFactoryPostProcessor(顶级父类)的组件，并执行他
	们的方法
	2）、在初始化创建其他组件前面执行
```

