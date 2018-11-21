# Spring-servlet3.0

## servlet3.0 注解

旧版的servlet listenser或者Spring mvc的Dispatcher控制器都是需要在web.xml进行注册。

servlet3.0 可以使用注解。代替web.xml的注册。tomcat7.0+才会支持servlet3.0

servlet3.0简单的样例

```java
@WebServlet("/hello")
public class HelloServlet extends HttpServlet {
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		// TODO Auto-generated method stub
		//super.doGet(req, resp);
		System.out.println(Thread.currentThread()+" start...");
		try {
			sayHello();
		} catch (Exception e) {
			e.printStackTrace();
		}
		resp.getWriter().write("hello...");
		System.out.println(Thread.currentThread()+" end...");
	}
	
	public void sayHello() throws Exception{
		System.out.println(Thread.currentThread()+" processing...");
		Thread.sleep(3000);
	}

}
```


## 插件-SPI

Shared libraries（共享库） / runtimes pluggability（运行时插件能力）

1、Servlet容器启动会扫描，当前应用里面每一个jar包的
	ServletContainerInitializer的实现
2、提供ServletContainerInitializer的实现类；
	必须绑定在，META-INF/services/javax.servlet.ServletContainerInitializer
	文件的内容就是ServletContainerInitializer实现类的全类名；


```java
@HandlesTypes(value={HelloService.class})
public class MyServletContainerInitializer implements ServletContainerInitializer{
	@Override
	public void onStartup(Set<Class<?>> arg0, ServletContext sc) throws ServletException {
		// TODO Auto-generated method stub
	}
}

```

1.@HandlesTypes 容器启动的时候会将@HandlesTypes指定的这个类型下面的子类（实现类，子接口等）传递过来；`变相的自动注入`

2.应用启动的时候，会运行onStartup方法；

3.Set<Class<?>> arg0：感兴趣的类型的所有子类型；ServletContext arg1:代表当前Web应用的ServletContext；一个Web应用一个ServletContext；

总结：容器在启动应用的时候，会扫描当前应用每一个jar包里面
META-INF/services/javax.servlet.ServletContainerInitializer
指定的实现类，启动并运行这个实现类的方法；传入感兴趣的类型；

## servlet 注册三大组件
使用ServletContext注册Web组件（Servlet、Filter、Listener）

使用编码的方式，在项目启动的时候给ServletContext里面添加组件；
	必须在项目启动的时候来添加；
	1）、ServletContainerInitializer得到的ServletContext；
	2）、ServletContextListener得到的ServletContext；

如果是我们自己编写的三大组件，都可以使用注解来进行注册，但是如果我们使用的是第三方的jar，那么注册就需要使用如下的方式。

实现ServletContainerInitializer#onStartup

```java
@Override
	public void onStartup(Set<Class<?>> arg0, ServletContext sc) throws ServletException {
		// TODO Auto-generated method stub
		System.out.println("感兴趣的类型：");
		for (Class<?> claz : arg0) {
			System.out.println(claz);
		}
		
		//注册组件  ServletRegistration  
		ServletRegistration.Dynamic servlet = sc.addServlet("userServlet", new UserServlet());
		//配置servlet的映射信息
		servlet.addMapping("/user");
		
		
		//注册Listener
		sc.addListener(UserListener.class);
		
		//注册Filter  FilterRegistration
		FilterRegistration.Dynamic filter = sc.addFilter("userFilter", UserFilter.class);
		//配置Filter的映射信息
		filter.addMappingForUrlPatterns(EnumSet.of(DispatcherType.REQUEST), true, "/*");
		
	}
```

1.注册组件有两种方式，一种提供Class servlet会自行创建，一种我们自己new

## 异步请求

关键点
1.开启异步**asyncSupported=true** `AsyncContext startAsync = req.startAsync();`

2.业务逻辑进行异步处理;开始异步处理 `startAsync.start()`

3.结束处理通知 `startAsync.complete();`

4.返回处理结果 `AsyncContext asyncContext = req.getAsyncContext() asyncContext.getResponse()`

```java
@WebServlet(value="/async",asyncSupported=true)
public class HelloAsyncServlet extends HttpServlet {
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		//1、支持异步处理asyncSupported=true
		//2、开启异步模式
		System.out.println("主线程开始。。。"+Thread.currentThread()+"==>"+System.currentTimeMillis());
		AsyncContext startAsync = req.startAsync();
		
		//3、业务逻辑进行异步处理;开始异步处理
		startAsync.start(new Runnable() {
			@Override
			public void run() {
				try {
					System.out.println("副线程开始。。。"+Thread.currentThread()+"==>"+System.currentTimeMillis());
					sayHello();
					startAsync.complete();
					//获取到异步上下文
					AsyncContext asyncContext = req.getAsyncContext();
					//4、获取响应
					ServletResponse response = asyncContext.getResponse();
					response.getWriter().write("hello async...");
					System.out.println("副线程结束。。。"+Thread.currentThread()+"==>"+System.currentTimeMillis());
				} catch (Exception e) {
				}
			}
		});		
		System.out.println("主线程结束。。。"+Thread.currentThread()+"==>"+System.currentTimeMillis());
	}

	public void sayHello() throws Exception{
		System.out.println(Thread.currentThread()+" processing...");
		Thread.sleep(3000);
	}
}
```

