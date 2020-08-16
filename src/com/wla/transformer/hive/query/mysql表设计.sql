# Host: localhost  (Version: 5.5.40)
# Date: 2020-07-30 22:29:08
# Generator: MySQL-Front 5.3  (Build 4.120)

/*!40101 SET NAMES utf8 */;

#
# Structure for table "dimension_browser"
#

DROP TABLE IF EXISTS `dimension_browser`;
CREATE TABLE `dimension_browser` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `browser_name` varchar(45) NOT NULL DEFAULT '' COMMENT '浏览器名称',
  `browser_version` varchar(255) NOT NULL DEFAULT '' COMMENT '浏览器版本号',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='浏览器维度信息表';


#
# Structure for table "dimension_date"
#

DROP TABLE IF EXISTS `dimension_date`;
CREATE TABLE `dimension_date` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `year` int(11) DEFAULT NULL,
  `season` int(11) DEFAULT NULL,
  `month` int(11) DEFAULT NULL,
  `week` int(11) DEFAULT NULL,
  `day` int(11) DEFAULT NULL,
  `calendar` date DEFAULT NULL,
  `type` enum('year','season','month','week','day') DEFAULT NULL COMMENT '日期格式',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='时间维度信息表';

#
# Structure for table "dimension_event"
#

DROP TABLE IF EXISTS `dimension_event`;
CREATE TABLE `dimension_event` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(255) DEFAULT NULL COMMENT '事件种类category',
  `action` varchar(255) DEFAULT NULL COMMENT '事件action名称',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='事件维度信息表';

#
# Structure for table "dimension_kpi"
#

DROP TABLE IF EXISTS `dimension_kpi`;
CREATE TABLE `dimension_kpi` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kpi_name` varchar(45) DEFAULT NULL COMMENT 'kpi维度名称',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='kpi维度相关信息表';

#
# Structure for table "dimension_location"
#

DROP TABLE IF EXISTS `dimension_location`;
CREATE TABLE `dimension_location` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `country` varchar(45) DEFAULT NULL COMMENT '国家名称',
  `province` varchar(45) DEFAULT NULL COMMENT '省份名称',
  `city` varchar(45) DEFAULT NULL COMMENT '城市名称',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='地域信息维度表';

#
# Structure for table "dimension_os"
#

DROP TABLE IF EXISTS `dimension_os`;
CREATE TABLE `dimension_os` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `os_name` varchar(45) NOT NULL DEFAULT '' COMMENT '操作系统名称',
  `os_version` varchar(45) NOT NULL DEFAULT '' COMMENT '操作系统版本号',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='操作系统信息维度表';


#
# Structure for table "dimension_platform"
#

DROP TABLE IF EXISTS `dimension_platform`;
CREATE TABLE `dimension_platform` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `platform_name` varchar(45) DEFAULT NULL COMMENT '平台名称',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='平台维度信息表';



#
# Structure for table "stats_device_browser"
#

DROP TABLE IF EXISTS `stats_device_browser`;
CREATE TABLE `stats_device_browser` (
  `date_dimension_id` int(11) NOT NULL,
  `platform_dimension_id` int(11) NOT NULL,
  `browser_dimension_id` int(11) NOT NULL DEFAULT '0',
  `active_users` int(11) DEFAULT '0' COMMENT '活跃用户数',
  `new_install_users` int(11) DEFAULT '0' COMMENT '新增用户数',
  `total_install_users` int(11) DEFAULT '0' COMMENT '总用户数',
  `pv` int(11) DEFAULT '0' COMMENT 'pv数',
  `created` date DEFAULT NULL,
  PRIMARY KEY (`platform_dimension_id`,`date_dimension_id`,`browser_dimension_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='统计浏览器相关分析数据的统计表';

#
# Structure for table "stats_device_location"
#

DROP TABLE IF EXISTS `stats_device_location`;
CREATE TABLE `stats_device_location` (
  `date_dimension_id` int(11) NOT NULL,
  `platform_dimension_id` int(11) NOT NULL,
  `location_dimension_id` int(11) NOT NULL DEFAULT '0',
  `active_users` int(11) DEFAULT '0' COMMENT '活跃用户数',
  `created` date DEFAULT NULL,
  PRIMARY KEY (`platform_dimension_id`,`date_dimension_id`,`location_dimension_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='统计地域相关分析数据的统计表';

#
# Structure for table "stats_event"
#

DROP TABLE IF EXISTS `stats_event`;
CREATE TABLE `stats_event` (
  `platform_dimension_id` int(11) NOT NULL DEFAULT '0',
  `date_dimension_id` int(11) NOT NULL DEFAULT '0',
  `event_dimension_id` int(11) NOT NULL DEFAULT '0',
  `times` int(11) DEFAULT '0' COMMENT '触发次数',
  `created` date DEFAULT NULL,
  PRIMARY KEY (`platform_dimension_id`,`date_dimension_id`,`event_dimension_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='统计事件相关分析数据的统计表';



#
# Structure for table "stats_view_depth"
#

DROP TABLE IF EXISTS `stats_view_depth`;
CREATE TABLE `stats_view_depth` (
  `platform_dimension_id` bigint(20) NOT NULL DEFAULT '0',
  `date_dimension_id` bigint(20) NOT NULL DEFAULT '0',
  `kpi_dimension_id` bigint(20) NOT NULL DEFAULT '0',
  `pv1` bigint(20) DEFAULT NULL,
  `pv2` bigint(20) DEFAULT NULL,
  `pv3` bigint(20) DEFAULT NULL,
  `pv4` bigint(20) DEFAULT NULL,
  `pv5_10` bigint(20) DEFAULT NULL,
  `pv10_30` bigint(20) DEFAULT NULL,
  `pv30_60` bigint(20) DEFAULT NULL,
  `pv60_plus` bigint(20) DEFAULT NULL,
  `created` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`platform_dimension_id`,`date_dimension_id`,`kpi_dimension_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='统计用户浏览深度相关分析数据的统计表';
