# Website_Log_Analysis
## 大数据项目-电商网站日志分析系统
### 1.数据流图
![](https://github.com/liuwencong666/Website_Log_Analysis/blob/master/pics/%E9%A1%B9%E7%9B%AE%E6%95%B0%E6%8D%AE%E6%B5%81%E5%9B%BE.jpg) 
### 2.数据流图解析
#### 2.1 整体流程
基于js埋点的方式访问Nginx并保存日志，通过flume将日志文件动态转移到HDFS中并按照时间对目录进行分级，
然后基于MR的方式实现ETL并把清洗好的数据保存到Hbase中，最后基于MR和Hive+Sqoop两种方式访问HBase中的数据，计算出最终结果并保存到MySQL中。<br>
本项目采用了四台虚拟机完成集群搭建

#### 2.2 JS SDK
该部分是为了收集用户访问的行为并在Server端获取到相应的日志。本项目通过在js代码中注册不同的事件函数并通过jsp页面进行调用来模拟日志采集这一功能。
当用户访问页面时，会自动加载埋点的js并执行业务逻辑采集信息，采集页面完成之后，访问<br>
    http://node0001/log.gif/<br>
把参数拼接到args后得到：<br>
    http://node0001/log.gif/?requestdata<br>
并发送给Nginx，Nginx在收到请求的同时记录日志。



