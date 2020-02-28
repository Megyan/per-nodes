# Elasticsearch

1.es为什么查询那么快

2.常见的优化策略 segment DocValue Merge 策略 时序场景


## source和docValue
倒排索引的特点很明显，就是为了全文检索而生的，但是对于一些聚合查询（排序、求平均值等等）的场景来说，显然不适用。那么这样一来我们为了应对一些聚合场景就需要结构化数据来应付，这里说的结构化数据就是『列存储』，也就是上面说的doc_value

## 写入
1.局部更新：根据ID从Segment段中获取完成的Doc，然后合并，插入新的，删除旧的。`本质还是删除，重新索引`

2.更新时。更新请求被主分片处理成Index或者Delete请求。主分片处理完后，会将对应的Index或者Delete请求转发给副本。

3.数据的写入，首先写入的Write Translog Flush Translog
![](../img/es-write.jpg)


[Elasticsearch内核剖析](https://zhuanlan.zhihu.com/p/35643348)

【重要】[ElasticSearch 内部机制浅析（三）](https://leonlibraries.github.io/2017/04/27/ElasticSearch%E5%86%85%E9%83%A8%E6%9C%BA%E5%88%B6%E6%B5%85%E6%9E%90%E4%B8%89/)

[Day7-Elasticsearch中数据是如何存储的](https://elasticsearch.cn/article/6178)

[Elasticsearch 5.x 源码分析（5）segments merge 流程分析](https://www.jianshu.com/p/9b872a41d5bb)

