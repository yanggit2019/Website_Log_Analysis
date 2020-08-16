# Website_Log_Analysis
## 大数据项目-网站日志分析系统
### 1.数据流图
![项目数据流图](https://github.com/liuwencong666/Website_Log_Analysis/blob/master/pics/项目数据流图.jpg) 
本项目的目的在于收集用户访问网站相关的行为所产生的日志，并基于大数据相关的技术实现日志数据的分布式存储及其ETL过程，最终实现对用户访问行为的统计与分析。<br>
注意，本仓库中包含代码只覆盖图中红框标记部分。<br>
### 2.数据流图解析
#### 2.1 整体流程<br>
基于js埋点的方式访问Nginx并保存日志，通过flume将日志文件动态转移到HDFS中并按照时间对目录进行分级，
然后基于MR的方式实现ETL并把清洗好的数据保存到Hbase中，最后基于MR和Hive+Sqoop两种方式访问HBase中的数据，计算出最终结果并保存到MySQL中。<br>
本项目采用了四台虚拟机完成集群搭建，相关配置如图所示：<br>
![配置图](https://github.com/liuwencong666/Website_Log_Analysis/blob/master/pics/配置图.jpg) 

#### 2.2 JS SDK
该部分是为了收集用户访问的行为并在Server端获取到相应的日志。本项目通过在js代码中注册不同的事件函数并通过jsp页面进行调用来模拟日志采集这一功能。
当用户访问页面时，会自动调用js函数执行相应逻辑，将采集到的信息拼接为uri的参数，例如: <br>
    http://node0001/log.gif/request_data <br>
其中request_data中包含以下基础字段(可扩充):<br>
![数据表](https://github.com/liuwencong666/Website_Log_Analysis/blob/master/pics/数据表格.jpg) 
拿到参数后向Nginx发送GET请求，Nginx在收到请求的同时记录日志到本地。<br>
日志中每一条记录的格式如下:<br>
客户端IP^A日志生成时间^A主机名^A参数<br>
例如:<br>
```
192.168.9.1^A1596783000.058^Anode0001^A/log.gif?en=e_pv&p_url=http%3A%2F%2Flocalhost%3A8080%2FBD%2Fdemo.jsp&tt=%E6%B5%8B%E8%AF%95%E9%A1%B5%E9%9D%A24&ver=1&pl=website&sdk=js&u_ud=7A6D4638-51B3-4375-A9FB-48B50670EB83&u_sd=FC45CF40-02BB-4669-B498-E291E8BA8445&c_time=1596784361940&l=zh-CN&b_iev=Mozilla%2F5.0%20(Windows%20NT%2010.0%3B%20WOW64)%20AppleWebKit%2F537.36%20(KHTML%2C%20like%20Gecko)%20Chrome%2F78.0.3904.108%20Safari%2F537.36&b_rst=1920*1080
```
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
Flume和Nginx均安装在node0001上。Flume的source组件类型设置为Exec Source,sink组件类型设置为HDFS Sink。 将log文件按照年/月/日的格式分级保存到HDFS目录中。
配置文件如下：
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
ETL相关代码在com.wla.etl包下。本步骤是对HDFS中的日志数据进行解析，包括IP地址到地理位置的解析，浏览器的userAgent信息的解析，request_data的解析。同时设定了一定的规则清洗掉错误的不规则的数据。将字段-服务器时间与加密后的字段-uuid进行拼接作为HBase表中的row key，参数字段类型作为列名，最终将清洗好的数据存储到HBase中。<br>
HBase中的每一条日志是按照ETL完成后的数据格式存储，单条数据格式如下:<br>
```
1596902354000_8280549             column=log:browser, timestamp=1597051605191, value=360                                         
1596902354000_8280549             column=log:browser_v, timestamp=1597051605191, value=2                                         
1596902354000_8280549             column=log:city, timestamp=1597051605191, value=\xE4\xB8\x9C\xE8\x8E\x9E\xE5\xB8\x82           
1596902354000_8280549             column=log:country, timestamp=1597051605191, value=\xE4\xB8\xAD\xE5\x9B\xBD                     
1596902354000_8280549             column=log:en, timestamp=1597051605191, value=e_l                                               
1596902354000_8280549             column=log:os, timestamp=1597051605191, value=ios                                               
1596902354000_8280549             column=log:os_v, timestamp=1597051605191, value=0                                               
1596902354000_8280549             column=log:p_url, timestamp=1597051605191, value=http://www.jd.com                             
1596902354000_8280549             column=log:pl, timestamp=1597051605191, value=website                                           
1596902354000_8280549             column=log:province, timestamp=1597051605191, value=\xE5\xB9\xBF\xE4\xB8\x9C\xE7\x9C\x81       
1596902354000_8280549             column=log:s_time, timestamp=1597051605191, value=1596902354000                                 
1596902354000_8280549             column=log:u_sd, timestamp=1597051605191, value=12344F83-6357-4A64-8527-F09216974234           
1596902354000_8280549             column=log:u_ud, timestamp=1597051605191, value=66179360
```
注意,为模拟大批量的日志数据,本项目采用了随机生成符合格式标准的日志的方式直接插入到了HBase的结果表中,同时也可以通过脚本调用JS端请求Nginx来获取大批量日志数据文件。
#### 2.5 HBase-MR & HBase-Hive-Sqoop
本步骤是对HBase中存储的清洗好的日志数据进行统计与分析，并将最终的结果存储到多个MySQL表中。<br>
MySQL表设计如下:<br>
```
1.维度表 dimension_browser,记录浏览器名称的id
2.维度表 dimension_date,记录时间维度(年/月/日/小时)的id
3.维度表 dimension_event,记录事件名称的id
4.维度表 dimension_kpi,记录维度组合kpi(launch/pageview等)的id
5.维度表 dimension_location,记录地理位置的id
6.维度表 dimension_os,记录客户端os名称的id
7.维度表 dimension_platform,记录平台名称的id
8.结果表 stats_device_browser,根据时间维度+平台名称+浏览器名称作为维度组合统计出相应时间区间内的新增用户数,活跃用户数,会话个数,pv数等
9.结果表 stats_device_location,根据时间维度+平台名称+地理位置名称作为维度组合统计出相应时间区间内的新增用户数，活跃用户数,会话个数,pv数等
10.结果表 stats_event,根据时间维度+事件名称统计出相应时间区间内的新增用户数，活跃用户数，会话个数，各维度记录数等
11.结果表 stats_view_depth,根据时间维度+平台名称+事件名称作为维度组合统计出相应时间区间内各访问深度的用户数量
```
在本项目中,基于MR的方式生成了1-10表的结果,将Hive作为HBase的一个客户端,使用HQL语句从HBase中的表计算出相应结果并保存结果到Hive表中,之后使用Sqoop将Hive表中数据转移到MySQL表中,基于该种方式生成了11-stats_view_depth的结果。<br>
HBase-MR相关代码在com.wla.transformer.mr包下。<br>
HBase-Hive相关自定义UDF类在com.wla.transformer.hive包下,MySQL建表sql文件与HQL文件在com.wla.transformer.hive.query包下。<br>
MySQL得到的结果以stats_device_browser表为例,该表一行中包含以下字段:<br>
```
date_dimension_id 1<br>
platform_ dimension_id 1
browser_dimension_id 25
active_users 18620
new_install_users 10000
total_users 28620
created 2020-08-07
```
Hive得到的结果以stats_view_depth表为例，该表一行中包含以下字段:<br>
```
platform_dimension_id 2
date_dimension_id 1
kpi_dimension_id 3
pv1 15200
pv2 8001
pv3 6023
pv4 5500
pv5_10 4800
pv10_30 865
pv30_60 602
pv60_plus 403
created 2020-08-05
```





