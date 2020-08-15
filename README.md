# Website_Log_Analysis
## 大数据项目-电商网站日志分析系统
### 1.数据流图
![项目数据流图](https://github.com/liuwencong666/Website_Log_Analysis/blob/master/pics/项目数据流图.jpg) 
注意，本仓库中包含代码只覆盖图中红框标记部分。<br>
### 2.数据流图解析
#### 2.1 整体流程<br>
基于js埋点的方式访问Nginx并保存日志，通过flume将日志文件动态转移到HDFS中并按照时间对目录进行分级，
然后基于MR的方式实现ETL并把清洗好的数据保存到Hbase中，最后基于MR和Hive+Sqoop两种方式访问HBase中的数据，计算出最终结果并保存到MySQL中。<br>
本项目采用了四台虚拟机完成集群搭建，相关配置如图所示：<br>
![配置图](https://github.com/liuwencong666/Website_Log_Analysis/blob/master/pics/配置图.jpg) 

#### 2.2 JS SDK
该部分是为了收集用户访问的行为并在Server端获取到相应的日志。本项目通过在js代码中注册不同的事件函数并通过jsp页面进行调用来模拟日志采集这一功能。
当用户访问页面时，会自动加载埋点的js并执行业务逻辑采集信息，采集页面完成之后，访问<br>
    http://node0001/log.gif/<br>
把参数拼接到args后得到：<br>
    http://node0001/log.gif/?requestdata<br>

拿到参数后向Nginx发送Http请求，Nginx在收到请求的同时记录日志到本地。<br>
Nginx的http模块配置如下(nginx/conf/nginx.conf)：
```
http {
    include       mime.types;
    default_type  application/octet-stream;
    log_format my_format '$remote_addr^A$msec^A$http_host^A$request_uri';
    sendfile        on;
    keepalive_timeout  65;
    server {
        listen       80;
        server_name  localhost;
        location / {
            root   html;
            index  index.html index.htm;
        }
        location =/log.gif{
            default_type image/gif;
            access_log /opt/data/access.log my_format;
        }
	}
}
```
#### 2.3 Flume
Flume和Nginx均安装在node0001上。Flume的source组件类型设置为Exec Source,sink组件类型设置为HDFS Sink。配置文件如下：
```
#日志数据通过flume传给hdfs设置
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
#通过exec的方式监控单个文件
a1.sources.r1.type = exec
a1.sources.r1.command = tail -F /opt/data/access.log

# Describe the sink
a1.sinks.k1.type = hdfs
a1.sinks.k1.channel = c1
a1.sinks.k1.hdfs.path = /log/%y%m%d
a1.sinks.k1.hdfs.filePrefix = events-
#文件大小
a1.sinks.k1.hdfs.rollInterval = 0
a1.sinks.k1.hdfs.rollSize = 1024000
a1.sinks.k1.hdfs.rollCount = 0
a1.sinks.k1.hdfs.useLocalTimeStamp = true
a1.sinks.k1.hdfs.callTimeout = 60000
a1.sinks.k1.hdfs.fileType = DataStream

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 100

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1
```
#### 2.4 ETL-MR



