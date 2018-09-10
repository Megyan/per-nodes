SpringBoot-自动加载的秘密
## IOC容器
**BeanDefinition**

```
容器中的每一个bean都会有一个对应的BeanDefinition实例，该实例负责保存bean对象的所有必要信息，包
括bean对象的class类型、是否是抽象类、构造方法和参数、其它属性等等
```

**BeanDefinitionRegistry**

```
BeanDefinitionRegistry抽象出bean的注册逻辑
```

**BeanFactory**

```
BeanFactory则抽象出了bean的管理逻辑，而各个BeanFactory的实现类就具体承担了bean的注册以及管理工作
```

**三者的关系：**
![](./img/factory.png)

**Spring IoC容器的整个工作流程**

* 1.初始化阶段。加载xml构造成BeanDefinition，然后注册到BeanDefinitionRegistry
* 2.实例化阶段。用户使用bean的时候，使用BeanFactory.getBean()。就对bean实例化，并为其注入依赖。实际上我们一般都使用了ApplicationContext来代替BeanFactory。

## JavaConfig

## 事件监听

## SpringFactoriesLoader详解





<https://www.jianshu.com/p/83693d3d0a65>


