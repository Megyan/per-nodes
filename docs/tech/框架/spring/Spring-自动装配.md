# Spring-自动装配


什么是自动装配?
`Spring利用依赖注入（DI），完成对IOC容器中中各个组件的依赖关系赋值；`

## 自动装配的方式

### Autowired 自动注入[Spring 定义的注解]

1 默认优先按照类型去容器中找对应的组件:applicationContext.getBean(BookDao.class);找到就赋值

2 如果找到多个相同类型的组件，再将属性的名称作为组件的id去容器中查找`applicationContext.getBean("bookDao")`
					
3 `@Qualifier("bookDao")`使用@Qualifier指定需要装配的组件的id，而不是使用属性名

4 自动装配默认一定要将属性赋值好，没有就会报错；可以使用`@Autowired(required=false);`

5 `@Primary`让Spring进行自动装配的时候，默认使用首选的bean；也可以继续使用@Qualifier指定需要装配的bean的名字

```java		
@Primary 和 @Qualifier 需要和@Autowired配合使用
BookService{
	 @Autowired
	 BookDao  bookDao;
}

@Primary
@Bean("bookDao2")
public BookDao bookDao(){
	BookDao bookDao = new BookDao();
	bookDao.setLable("2");
	return bookDao;
}
```
### Spring还支持使用@Resource(JSR250)和@Inject(JSR330)[java规范的注解]

@Resource：可以和@Autowired一样实现自动装配功能；默认是按照组件名称进行装配的；
没有能支持@Primary功能，没有支持@Autowired（reqiured=false）;
	
@Inject：需要导入javax.inject的包，和Autowired的功能一样。没有required=false的功能；
	
@Autowired:Spring定义的； 

@Resource、@Inject都是java规范。AutowiredAnnotationBeanPostProcessor:解析完成自动装配功能；		

### @Autowired:构造器，参数，方法，属性；都是从容器中获取参数组件的值

1 [标注在方法位置]：@Bean+方法参数；参数从容器中获取;默认不写@Autowired效果是一样的；都能自动装配

```java
public class Boss {
   private Car car;
   
	@Autowired 
	//标注在方法，Spring容器创建当前对象，就会调用方法，完成赋值；
	//方法使用的参数，自定义类型的值从ioc容器中获取
	public void setCar(Car car) {
		this.car = car;
	}
}
```

2 [标在构造器上]：如果组件只有一个有参构造器，这个有参构造器的@Autowired可以省略，参数位置的组件还是可以自动从容器中获取

```java
@Component
public class Boss {
	
	
	private Car car;
	
	//构造器要用的组件，都是从容器中获取
	//Only 一个有参构造器,注解可以省略
	@Autowired 
	public Boss(Car car){
		this.car = car;
		System.out.println("Boss...有参构造器");
	}
}
```
3 放在参数位置：

```java
public class Boss {
   private Car car;
   
	
	//标注在方法，Spring容器创建当前对象，就会调用方法，完成赋值；
	//方法使用的参数，自定义类型的值从ioc容器中获取
	public void setCar(@Autowired Car car) {
		this.car = car;
	}
}
```

4)、 new Bean的方式

```java
@Configuration
public class MainConifgOfAutowired {
	
	/**
	 * @Bean标注的方法创建对象的时候，方法参数的值从容器中获取
	 * @param car
	 * @return
	 */
	@Bean
	public Color color(Car car){
		Color color = new Color();
		color.setCar(car);
		return color;
	}

}
```

### 自定义组件想要使用Spring容器底层的一些组件（ApplicationContext，BeanFactory，xxx）

自定义组件实现xxxAware；

在创建对象的时候，会调用接口规定的方法注入相关组件；Aware；

把Spring底层一些组件注入到自定义的Bean中；

xxxAware：功能使用xxxProcessor；
ApplicationContextAware==》ApplicationContextAwareProcessor；
	
在对象创建的时候就会被调用
这个同Spring-Bean的生命周期的内容就联系起来了	

```java
@Component
public class Red implements ApplicationContextAware,BeanNameAware,EmbeddedValueResolverAware {
	
	private ApplicationContext applicationContext;

	@Override
	public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
		// TODO Auto-generated method stub
		System.out.println("传入的ioc："+applicationContext);
		this.applicationContext = applicationContext;
	}

	@Override
	public void setBeanName(String name) {
		// TODO Auto-generated method stub
		System.out.println("当前bean的名字："+name);
	}

	@Override
	public void setEmbeddedValueResolver(StringValueResolver resolver) {
		// TODO Auto-generated method stub
		String resolveStringValue = resolver.resolveStringValue("你好 ${os.name} 我是 #{20*18}");
		System.out.println("解析的字符串："+resolveStringValue);
	}
}
```

## Profile


什么是Profile?

```
Spring为我们提供的可以根据当前环境，动态的激活和切换一系列组件的功能；
举个例子:三个环境对应不同的数据源
开发环境、测试环境、生产环境；
数据源：(/A)(/B)(/C)；
```

@Profile：指定组件在哪个环境的情况下才能被注册到容器中，不指定，任何环境下都能注册这个组件

1 加了环境标识的bean，只有这个环境被激活的时候才能注册到容器中。默认是default环境

2 写在配置类上，只有是指定的环境的时候，整个配置类里面的所有配置才能开始生效

3 没有标注环境标识的bean在，任何环境下都是加载的；


```java
@PropertySource("classpath:/dbconfig.properties")
@Configuration
public class MainConfigOfProfile implements EmbeddedValueResolverAware{
	
	@Value("${db.user}")
	private String user;
	
	private StringValueResolver valueResolver;
	
	private String  driverClass;
	
	
	@Bean
	public Yellow yellow(){
		return new Yellow();
	}
	
	@Profile("test")
	@Bean("testDataSource")
	public DataSource dataSourceTest(@Value("${db.password}")String pwd) throws Exception{
		ComboPooledDataSource dataSource = new ComboPooledDataSource();
		dataSource.setUser(user);
		dataSource.setPassword(pwd);
		dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/test");
		dataSource.setDriverClass(driverClass);
		return dataSource;
	}
	
		
	@Profile("dev")
	@Bean("devDataSource")
	public DataSource dataSourceDev(@Value("${db.password}")String pwd) throws Exception{
		ComboPooledDataSource dataSource = new ComboPooledDataSource();
		dataSource.setUser(user);
		dataSource.setPassword(pwd);
		dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/ssm_crud");
		dataSource.setDriverClass(driverClass);
		return dataSource;
	}
}
```

使用方式:

1、JVM参数 `-Dspring.profiles.active=dev`

2、代码的方式激活某种环境；

```java
public void test01(){
		AnnotationConfigApplicationContext applicationContext = 
				new AnnotationConfigApplicationContext();
		//1、创建一个applicationContext
		//2、设置需要激活的环境
		applicationContext.getEnvironment().setActiveProfiles("dev");
		//3、注册主配置类
		applicationContext.register(MainConfigOfProfile.class);
		//4、启动刷新容器
		applicationContext.refresh();
		
}
```


