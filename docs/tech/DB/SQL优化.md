# 数据库SQL优化

1.对查询进行优化，要尽量避免全表扫描，首先应考虑在 where 及 order by 涉及的列上建立索引

2.应尽量避免在 where 子句中对字段进行 null 值判断，否则将导致引擎放弃使用索引而进行全表扫描

```sql
select id from t where num is null
```

3.应尽量避免在 where 子句中使用 != 或 <> 操作符，否则将引擎放弃使用索引而进行全表扫描。

4.in 和 not in 也要慎用，否则会导致全表扫描

对于连续的数值，能用 **between** 就不要用 in 了

```sql
select id from t where num between 1 and 3
```
很多时候用 exists 代替 in 是一个好的选择,比如:

```sql
select num from a where num in(select num from b)
# 替换成
select num from a where exists(select 1 from b where num=a.num)
```
5.like中非前缀查询也会使用全表扫描

6.如果在 where 子句中使用参数，也会导致全表扫描.可以强制指定索引

```sql
select id from t where num = @num
# 改为
select id from t with(index(索引名)) where num = @num
```

7.应尽量避免在 where 子句中对字段进行表达式操作，这将导致引擎放弃使用索引而进行全表扫描

```sql
select id from t where num/2 = 100
# 改为
select id from t where num = 100*2
```

8.应尽量避免在where子句中对字段进行函数操作，这将导致引擎放弃使用索引而进行全表扫描。如

```sql
select id from t where substring(name,1,3) = ’abc’       -–name以abc开头的id
select id from t where datediff(day,createdate,’2005-11-30′) = 0    -–‘2005-11-30’    --生成的id
# 改为
select id from t where name like 'abc%'
select id from t where createdate >= '2005-11-30' and createdate < '2005-12-1'
```

9.不要在 where 子句中的“=”左边进行函数、算术运算或其他表达式运算，否则系统将可能无法正确使用索引
`见来说,就是如果一定有要对字段进行操作,那么该操作在where子句中的顺序越靠后越好`

10.对于多张大数据量（这里几百条就算大了）的表JOIN，要先分页再JOIN，否则逻辑读会很高，性能很差
`在进行表链接的时候,应尽量减少结果集`

11.**select count(*) from table；这样不带任何条件的count会引起全表扫描，并且没有任何业务意义，是一定要杜绝的**

12.索引并不是越多越好，索引固然可以提高相应的 select 的效率，但同时也降低了 insert 及 update 的效率，因为 insert 或 update 时有可能会重建索引，所以怎样建索引需要慎重考虑，视具体情况而定。一个表的索引数最好不要超过6个，若太多则应考虑一些不常使用到的列上建的索引是否有 必要

13.尽量使用数字型字段，若只含数值信息的字段尽量不要设计为字符型，这会降低查询和连接的性能，并会增加存储开销。这是因为引擎在处理查询和连 接时会逐个比较字符串中每一个字符，而对于数字型而言只需要比较一次就够了
`能用数字就使用数字类型`

14.尽可能的使用 varchar/nvarchar 代替 char/nchar ，因为首先变长字段存储空间小，可以节省存储空间，其次对于查询来说，在一个相对较小的字段内搜索效率显然要高些

15.任何地方都不要使用 select * from t ，用具体的字段列表代替“*”，不要返回用不到的任何字段

16.在新建临时表时，如果一次性插入数据量很大，那么可以使用 select into 代替 create table，避免造成大量 log ，以提高速度；如果数据量不大，为了缓和系统表的资源，应先create table，然后insert

17.**尽量避免使用游标，因为游标的效率较差，如果游标操作的数据超过1万行，那么就应该考虑改写**

18.尽量避免向客户端返回大数据量，若数据量过大，应该考虑相应需求是否合理。


```
实际案例分析：拆分大的 DELETE 或INSERT 语句，批量提交SQL语句

如果你需要在一个在线的网站上去执行一个大的 DELETE 或 INSERT 查询，你需要非常小心，要避免你的操作让你的整个网站停止相应。因为这两个操作是会锁表的，表一锁住了，别的操作都进不来了
```

**参考**
<https://www.cnblogs.com/yunfeifei/p/3850440.html>


