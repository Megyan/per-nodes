# RPC框架 

## RPC Demo的简要实现要点

这个简单的例子的实现思路是:

* 使用阻塞的socket IO流来进行server和client的通信，也就是rpc应用中服务提供方和服务消费方。并且是端对端的，用端口号来直接进行通信
* 方法的远程调用使用的是jdk的动态代理
* 参数的序列化也是使用的最简单的objectStream

## 核心模块

一般服务框架的核心模块应该有注册中心、网络通信、服务编码（通信协议、序列化）、服务路由、负载均衡，服务鉴权，可用性保障（服务降级、服务限流、服务隔离）、服务监控（Metrics、Trace）、配置中心、服务治理平台


**参考**
<https://www.xilidou.com/2018/09/26/dourpc-remoting/>
<https://juejin.im/post/5bbe0a5fe51d450e9163088d?utm_source=gold_browser_extension>

