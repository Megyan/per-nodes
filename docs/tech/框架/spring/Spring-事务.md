# Spring-声明事务

## 使用事务

1、导入相关依赖 数据源、数据库驱动、Spring-jdbc模块
		
2、配置数据源、JdbcTemplate（Spring提供的简化数据库操作的工具）操作数据

3、给方法上标注 @Transactional 表示当前方法是一个事务方法；

4、 @EnableTransactionManagement 开启基于注解的事务管理功能；@EnableXXX
		
5、配置事务管理器来控制事务;

```java
   //注册事务管理器在容器中
	@Bean
	public PlatformTransactionManager transactionManager() throws Exception{
		return new DataSourceTransactionManager(dataSource());
	}
```

configuration 类中获取Bean的特殊方式

```java
   @Bean
	public JdbcTemplate jdbcTemplate() throws Exception{
		//Spring对@Configuration类会特殊处理；
		//给容器中加组件的方法，多次调用都只是从容器中找组件
		JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource());
		return jdbcTemplate;
	}
```


## 原理分析 

1）@EnableTransactionManagement

利用TransactionManagementConfigurationSelector给容器中会导入组件
导入两个组件`AutoProxyRegistrar`和`ProxyTransactionManagementConfiguration`
			
2）AutoProxyRegistrar的作用

给容器中注册一个 `InfrastructureAdvisorAutoProxyCreator` 组件；`InfrastructureAdvisorAutoProxyCreator` 是个后置处理器；
利用后置处理器机制在对象创建以后，包装对象，返回一个代理对象（增强器），代理对象执行方法利用拦截器链进行调用；

3）ProxyTransactionManagementConfiguration 做了什么？

给容器中注册事务增强器；

```
1）事务增强器要用事务注解的信息，AnnotationTransactionAttributeSource解析事务注解
2）事务拦截器：
	TransactionInterceptor；保存了事务属性信息，事务管理器；
	他是一个 MethodInterceptor；
	在目标方法执行的时候；会执行拦截器链；
		事务拦截器：
			1）先获取事务相关的属性
			2）再获取PlatformTransactionManager，如果事先没有添加指定任何
			    transactionmanger最终会从容器中按照类型获取一个
			    PlatformTransactionManager；
			3）执行目标方法
				如果异常，获取到事务管理器，利用事务管理回滚操作；
				如果正常，利用事务管理器，提交事务
				
```	


### 其他

方法拦截器 就是对真实目标方法的包装，比如

```
拦截器.invoke(目标对象){
    // 拦截器的工作
    目标对象.目标方法
}
```

增强器呢，就是对方法拦截器的包装，它比方法拦截器多了一些上下文，提供拦截器工作的必要入参

那么事务管理器是怎么回滚的呢？是基于数据库提供的回滚功能。
Spring提供的事务是简化了代码量，不用开发者去try catch 去编写调用数据库回滚的API，本质上还是AOP

