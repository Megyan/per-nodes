CREATE TABLE `order_demo` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
  `order_id` bigint(20) NOT NULL COMMENT '订单号',
  `order_state` tinyint(3) NOT NULL COMMENT '订单状态',
  `platform` tinyint(3) NOT NULL COMMENT '订单来源（平台）',
  `pin` varchar(50) NOT NULL COMMENT '用户pin',
  `order_create_date` datetime NOT NULL COMMENT '订单创建时间',
  `store_id` bigint(20) DEFAULT NULL COMMENT '门店id',
  `store_name`  varchar(50) DEFAULT NULL COMMENT '门店名称',
  `version` bigint(20) NOT NULL DEFAULT '0' COMMENT 'version',
  `modified` datetime NOT NULL COMMENT 'modified',
  `created` datetime NOT NULL COMMENT 'created',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_order_id` (`order_id`) USING BTREE COMMENT 'order uniq',
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='测试订单信息';