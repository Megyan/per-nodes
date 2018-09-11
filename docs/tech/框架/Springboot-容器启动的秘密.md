SpringBoot-自动加载的秘密
## IOC容器
#### Bean的new
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

#### Bean的改动
IoC容器负责管理容器中所有bean的生命周期，而在bean生命周期的不同阶段，Spring提供了不同的扩展点来改变bean的命运。在容器的启动阶段。

**BeanFactoryPostProcessor**

```
允许我们在容器实例化相应对象之前，对注册到容器的BeanDefinition所保存的信息做一些额外的操作，比
如修改bean定义的某些属性或者增加其他信息

例如PropertyPlaceholderConfigurer作为BeanFactoryPostProcessor被应用时，它会使用
properties配置文件中的值来替换相应的BeanDefinition中占位符所表示的属性值
```

**BeanPostProcessor**

```
跟BeanFactoryPostProcessor类似，它会处理容器内所有符合条件并且已经实例化后的对象。简单的对
比，BeanFactoryPostProcessor处理bean的定义，而BeanPostProcessor则处理bean完成实例化后的
对象
```

![](./img/beanPostProcessor.jpg)

BeanPostProcessor中的postProcessBeforeInitialization()方法与postProcessAfterInitialization()分别对应图中前置处理和后置处理两个步骤将执行的方法

```
再来看一个更常见的例子，在Spring中经常能够看到各种各样的Aware接口，其作用就是在对象实例化完成以
后将Aware接口定义中规定的依赖注入到当前实例中。比如最常见的ApplicationContextAware接口，实现
了这个接口的类都可以获取到一个ApplicationContext对象。当容器中每个对象的实例化过程走到
BeanPostProcessor前置处理这一步时，容器会检测到之前注册到容器的
ApplicationContextAwareProcessor，然后就会调用其postProcessBeforeInitialization()方
法，检查并设置Aware相关依赖
```

## JavaConfig与常见Annotation
#### JavaConfig的前世今生
因为Spring项目的所有业务类均以bean的形式配置在XML文件中，造成了大量的XML文件，使项目变得复杂且难以管理。
JavaConfig子项目，它基于Java代码和Annotation注解来描述bean之间的依赖绑定关系。


XML配置方式来描述bean的定义：

```
<bean id="bookService" class="cn.moondev.service.BookServiceImpl"></bean>
```

而基于JavaConfig的配置形式是这样的：**SpringBoot 就是这么玩儿的**

```
@Configuration
public class MoonBookConfiguration {

    // 任何标志了@Bean的方法，其返回值将作为一个bean注册到Spring的IOC容器中
    // 方法名默认成为该bean定义的id
    @Bean
    public BookService bookService() {
        return new BookServiceImpl();
    }
}
```
两个bean之间有依赖关系的话，JavaConfig是这样的：

```
@Configuration
public class MoonBookConfiguration {

    // 如果一个bean依赖另一个bean，则直接调用对应JavaConfig类中依赖bean的创建方法即可
    // 这里直接调用dependencyService()
    @Bean
    public BookService bookService() {
        return new BookServiceImpl(dependencyService());
    }

    @Bean
    public OtherService otherService() {
        return new OtherServiceImpl(dependencyService());
    }

    @Bean
    public DependencyService dependencyService() {
        return new DependencyServiceImpl();
    }
}
```
#### 常见的注解

**@ComponentScan**
@ComponentScan注解对应XML配置形式中的<context:component-scan>元素，表示启用组件扫描，Spring会自动扫描所有通过注解配置的bean，然后将其注册到IOC容器中。我们可以通过basePackages等属性来指定@ComponentScan自动扫描的范围，如果不指定，默认从声明@ComponentScan所在类的package进行扫描。正因为如此，SpringBoot的启动类都默认在src/main/java下

`实际上，Springboot项目一般使用@SpringBootApplication 其中就包含了@ComponentScan`

**@Import**
@Import注解用于导入配置类，举个简单的例子：

```
@Configuration
public class MoonBookConfiguration {
    @Bean
    public BookService bookService() {
        return new BookServiceImpl();
    }
}
```
现在有另外一个配置类，比如：MoonUserConfiguration，这个配置类中有一个bean依赖于MoonBookConfiguration中的bookService，如何将这两个bean组合在一起？借助@Import即可：

```
@Configuration
// 可以同时导入多个配置类，比如：@Import({A.class,B.class})
@Import(MoonBookConfiguration.class)
public class MoonUserConfiguration {
    @Bean
    public UserService userService(BookService bookService) {
        return new BookServiceImpl(bookService);
    }
}
```

**@Conditional**

@Conditional注解表示在满足某种条件后才初始化一个bean或者启用某些配置。它一般用在由@Component、@Service、@Configuration等注解标识的类上面，或者由@Bean标记的方法上。如果一个@Configuration类标记了@Conditional，则该类中所有标识了@Bean的方法和@Import注解导入的相关类将遵从这些条件

我们可以通过实现Condition接口的matches()自定义这些Conditional.

<http://forlan.iteye.com/blog/2422298>

**@ConfigurationProperties与@EnableConfigurationProperties**
当某些属性的值需要配置的时候，我们一般会在application.properties文件中新建配置项，然后在bean中使用@Value注解来获取配置的值。假如我们很多地方用这个属性，但是我们要改属性名称呢？
对于更为复杂的配置，Spring Boot提供了更优雅的实现方式，那就是@ConfigurationProperties注解。
`@ConfigurationProperties 是将指定的注解文件或者前缀内的属性注入到对应bean中`

```
@Component
//  还可以通过@PropertySource("classpath:jdbc.properties")来指定配置文件
@ConfigurationProperties("jdbc.mysql")
// 前缀=jdbc.mysql，会在配置文件中寻找jdbc.mysql.*的配置项
pulic class JdbcConfig {
    public String url;
    public String username;
    public String password;
}

@Configuration
public class HikariDataSourceConfiguration {

    @AutoWired
    public JdbcConfig config;
    
    @Bean
    public HikariDataSource dataSource() {
        HikariConfig hikariConfig = new HikariConfig();
        hikariConfig.setJdbcUrl(config.url);
        hikariConfig.setUsername(config.username);
        hikariConfig.setPassword(config.password);
        // 省略部分代码
        return new HikariDataSource(hikariConfig);
    }
}
```

`@EnableConfigurationProperties注解表示对@ConfigurationProperties的内嵌支持，默认会将对应Properties Class作为bean注入的IOC容器中，即在相应的Properties类上不用加@Component注解`

## 事件监听

## 类加载SpringFactoriesLoader

**JVM的类加载器**
JVM提供了3种类加载器：BootstrapClassLoader、ExtClassLoader、AppClassLoader分别加载Java核心类库、扩展类库以及应用的类路径(CLASSPATH)下的类库。JVM通过双亲委派模型进行类的加载，我们也可以通过继承java.lang.classloader实现自己的类加载器






<https://www.jianshu.com/p/83693d3d0a65>


