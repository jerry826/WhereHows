--
-- Copyright 2015 LinkedIn Corp. All rights reserved.
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--

-- create statement for dataset related tables :
-- dict_dataset, dict_dataset_sample, dict_field_detail, dict_dataset_schema_history

-- stagging table for dataset
CREATE TABLE `stg_dict_dataset` (
  `name`                        VARCHAR(200) NOT NULL,
  `schema`                      MEDIUMTEXT CHARACTER SET utf8,
  `schema_type`                 VARCHAR(50) DEFAULT 'JSON' COMMENT 'JSON, Hive, DDL, XML, CSV',
  `properties`                  TEXT CHARACTER SET utf8,
  `fields`                      MEDIUMTEXT CHARACTER SET utf8,
  `db_id`                       SMALLINT UNSIGNED,
  `urn`                         VARCHAR(200) NOT NULL,
  `source`                      VARCHAR(50) NULL,
  `location_prefix`             VARCHAR(200) NULL,
  `parent_name`                 VARCHAR(200) NULL COMMENT 'Schema Name for RDBMS, Group Name for Jobs/Projects/Tracking Datasets on HDFS',
  `storage_type`                ENUM('Table', 'View', 'Avro', 'ORC', 'RC', 'Sequence', 'Flat File', 'JSON', 'XML', 'Thrift', 'Parquet', 'Protobuff') NULL,
  `ref_dataset_name`            VARCHAR(200) NULL,
  `ref_dataset_id`              INT(11) UNSIGNED NULL COMMENT 'Refer to Master/Main dataset for Views/ExternalTables',
  `status_id`                   SMALLINT(6) UNSIGNED NULL COMMENT 'Reserve for dataset status',
  `dataset_type`                VARCHAR(30) NULL
  COMMENT 'hdfs, hive, kafka, teradata, mysql, sqlserver, file, nfs, pinot, salesforce, oracle, db2, netezza, cassandra, hbase, qfs, zfs',
  `hive_serdes_class`           VARCHAR(300)                                                                                NULL,
  `is_partitioned`              CHAR(1)                                                                                     NULL,
  `partition_layout_pattern_id` SMALLINT(6)                                                                                 NULL,
  `sample_partition_full_path`  VARCHAR(256) COMMENT 'sample partition full path of the dataset',
  `source_created_time`         INT UNSIGNED                                                                                NULL
  COMMENT 'source created time of the flow',
  `source_modified_time`        INT UNSIGNED                                                                                NULL
  COMMENT 'latest source modified time of the flow',
  `created_time`                INT UNSIGNED COMMENT 'wherehows created time',
  `modified_time`               INT UNSIGNED COMMENT 'latest wherehows modified',
  `wh_etl_exec_id`              BIGINT COMMENT 'wherehows etl execution id that modified this record',
  PRIMARY KEY (`urn`, `db_id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = latin1
  PARTITION BY HASH(db_id)
  PARTITIONS 8;

-- dataset table
CREATE TABLE `dict_dataset` (
  `id`                          INT(11) UNSIGNED NOT NULL                                                                   AUTO_INCREMENT,
  `name`                        VARCHAR(200) CHARACTER SET utf8                                                             NOT NULL,
  `schema`                      MEDIUMTEXT CHARACTER SET utf8,
  `schema_type`                 VARCHAR(50)                                                                                 DEFAULT 'JSON'
  COMMENT 'JSON, Hive, DDL, XML, CSV',
  `properties`                  TEXT CHARACTER SET utf8,
  `fields`                      MEDIUMTEXT CHARACTER SET utf8,
  `urn`                         VARCHAR(200) CHARACTER SET utf8                                                             NOT NULL,
  `source`                      VARCHAR(50)                                                                                 NULL
  COMMENT 'The original data source type (for dataset in data warehouse). Oracle, Kafka ...',
  `location_prefix`             VARCHAR(200)                                                                                NULL,
  `parent_name`                 VARCHAR(200)                                                                                NULL
  COMMENT 'Schema Name for RDBMS, Group Name for Jobs/Projects/Tracking Datasets on HDFS ',
  `storage_type`                ENUM('Table', 'View', 'Avro', 'ORC', 'RC', 'Sequence', 'Flat File', 'JSON', 'XML', 'Thrift', 'Parquet', 'Protobuff') NULL,
  `ref_dataset_id`              INT(11) UNSIGNED                                                                            NULL
  COMMENT 'Refer to Master/Main dataset for Views/ExternalTables',
  `status_id`                   SMALLINT(6) UNSIGNED                                                                        NULL
  COMMENT 'Reserve for dataset status',
  `dataset_type`                VARCHAR(30)                                                                                 NULL
  COMMENT 'hdfs, hive, kafka, teradata, mysql, sqlserver, file, nfs, pinot, salesforce, oracle, db2, netezza, cassandra, hbase, qfs, zfs',
  `hive_serdes_class`           VARCHAR(300)                                                                                NULL,
  `is_partitioned`              CHAR(1)                                                                                     NULL,
  `partition_layout_pattern_id` SMALLINT(6)                                                                                 NULL,
  `sample_partition_full_path`  VARCHAR(256)
  COMMENT 'sample partition full path of the dataset',
  `source_created_time`         INT UNSIGNED                                                                                NULL
  COMMENT 'source created time of the flow',
  `source_modified_time`        INT UNSIGNED                                                                                NULL
  COMMENT 'latest source modified time of the flow',
  `created_time`                INT UNSIGNED COMMENT 'wherehows created time',
  `modified_time`               INT UNSIGNED COMMENT 'latest wherehows modified',
  `wh_etl_exec_id`              BIGINT COMMENT 'wherehows etl execution id that modified this record',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_dataset_urn` (`urn`),
  FULLTEXT KEY `fti_datasets_all` (`name`, `schema`, `properties`, `urn`)
)
  ENGINE = InnoDB
  AUTO_INCREMENT = 0
  DEFAULT CHARSET = latin1;

-- stagging table for sample data
CREATE TABLE `stg_dict_dataset_sample` (
  `db_id`      SMALLINT  UNSIGNED,
  `urn`        VARCHAR(200) NOT NULL DEFAULT '',
  `dataset_id` INT(11)               NULL,
  `ref_urn`    VARCHAR(200)          NULL,
  `ref_id`     INT(11)               NULL,
  `data`       MEDIUMTEXT,
  PRIMARY KEY (`db_id`, `urn`),
  KEY `ref_urn_key` (`ref_urn`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

-- sample data table
CREATE TABLE `dict_dataset_sample` (
  `id`         INT(11) NOT NULL AUTO_INCREMENT,
  `dataset_id` INT(11)          NULL,
  `urn`        VARCHAR(200)     NULL,
  `ref_id`     INT(11)          NULL
  COMMENT 'Reference dataset id of which dataset that we fetch sample from. e.g. for tables we do not have permission, fetch sample data from DWH_STG correspond tables',
  `data`       MEDIUMTEXT,
  `modified`   DATETIME         NULL,
  `created`    DATETIME         NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ak_dict_dataset_sample__dataset_id` (`dataset_id`)
)
  ENGINE = InnoDB
  AUTO_INCREMENT = 0
  DEFAULT CHARSET = utf8;

-- stagging table for field detail
CREATE TABLE `stg_dict_field_detail` (
  `db_id`          SMALLINT  UNSIGNED,
  `urn`            VARCHAR(200)         NOT NULL,
  `sort_id`        SMALLINT(5) UNSIGNED NOT NULL,
  `parent_sort_id` SMALLINT(5) UNSIGNED NOT NULL,
  `parent_path`    VARCHAR(200)                  NULL,
  `field_name`     VARCHAR(100)         NOT NULL,
  `field_label`    VARCHAR(100)                  NULL,
  `data_type`      VARCHAR(50)          NOT NULL,
  `data_size`      INT(10) UNSIGNED              NULL,
  `data_precision` TINYINT(3) UNSIGNED           NULL,
  `data_scale`     TINYINT(3) UNSIGNED           NULL,
  `is_nullable`    CHAR(1)                       NULL,
  `is_indexed`     CHAR(1)                       NULL,
  `is_partitioned` CHAR(1)                       NULL,
  `is_distributed` CHAR(1)                       NULL,
  `default_value`  VARCHAR(200)                  NULL,
  `namespace`      VARCHAR(200)                  NULL,
  `description`    VARCHAR(1000)                 NULL,
  `last_modified`  TIMESTAMP            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `dataset_id`     INT UNSIGNED         NULL COMMENT 'used to opitimize metadata ETL performance',
  KEY `idx_stg_dict_field_detail__description` (`description`(100)),
  PRIMARY KEY (`urn`, `sort_id`, `db_id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8
  PARTITION BY HASH(db_id)
  PARTITIONS 8;

-- field detail table
CREATE TABLE `dict_field_detail` (
  `field_id`           INT(11) UNSIGNED     NOT NULL AUTO_INCREMENT,
  `dataset_id`         INT(11) UNSIGNED     NOT NULL,
  `fields_layout_id`   INT(11) UNSIGNED     NOT NULL,
  `sort_id`            SMALLINT(6) UNSIGNED NOT NULL,
  `parent_sort_id`     SMALLINT(5) UNSIGNED NOT NULL,
  `parent_path`        VARCHAR(250)                  NULL,
  `field_name`         VARCHAR(100)         NOT NULL,
  `field_label`        VARCHAR(100)                  NULL,
  `data_type`          VARCHAR(50)          NOT NULL,
  `data_size`          INT(10) UNSIGNED              NULL,
  `data_precision`     TINYINT(4)                    NULL
  COMMENT 'only in decimal type',
  `data_fraction`      TINYINT(4)                    NULL
  COMMENT 'only in decimal type',
  `default_comment_id` INT(11) UNSIGNED              NULL
  COMMENT 'a list of comment_id',
  `comment_ids`        VARCHAR(500)                  NULL,
  `is_nullable`        CHAR(1)                       NULL,
  `is_indexed`         CHAR(1)                       NULL
  COMMENT 'only in RDBMS',
  `is_partitioned`     CHAR(1)                       NULL
  COMMENT 'only in RDBMS',
  `is_distributed`     TINYINT(4)                    NULL
  COMMENT 'only in RDBMS',
  `default_value`      VARCHAR(200)                  NULL,
  `namespace`          VARCHAR(200)                  NULL,
  `java_data_type`     VARCHAR(50)                   NULL
  COMMENT 'correspond type in java',
  `jdbc_data_type`     VARCHAR(50)                   NULL
  COMMENT 'correspond type in jdbc',
  `pig_data_type`      VARCHAR(50)                   NULL
  COMMENT 'correspond type in pig',
  `hcatalog_data_type` VARCHAR(50)                   NULL
  COMMENT 'correspond type in hcatalog',
  `modified`           TIMESTAMP            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`field_id`),
  KEY `idx_dict_field__datasetid_fieldname` (`dataset_id`, `field_name`) USING BTREE,
  KEY `idx_dict_field__fieldslayoutid` (`fields_layout_id`) USING BTREE
)
  ENGINE = InnoDB
  AUTO_INCREMENT = 0
  DEFAULT CHARSET = utf8
  COMMENT = 'Fields/Columns';

-- schema history
CREATE TABLE `dict_dataset_schema_history` (
  `id`            INT(11) AUTO_INCREMENT NOT NULL,
  `dataset_id`    INT(11)                NULL,
  `urn`           VARCHAR(200)           NOT NULL,
  `modified_date` DATE                   NULL,
  `schema`        MEDIUMTEXT CHARACTER SET utf8 NULL,
  PRIMARY KEY (id),
  UNIQUE KEY `uk_dict_dataset_schema_history__urn_modified` (`urn`, `modified_date`)
)
  ENGINE = InnoDB
  AUTO_INCREMENT = 0;

-- staging table table of fields to comments mapping
CREATE TABLE `stg_dict_dataset_field_comment` (
  `field_id` bigint(20) NOT NULL,
  `comment_id` bigint(20) NOT NULL,
  `dataset_id` bigint(20) NOT NULL,
  `db_id` smallint(6) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`field_id`,`comment_id`)
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8
;

-- fields to comments mapping
CREATE TABLE `dict_dataset_field_comment` (
  `field_id`   BIGINT(20) NOT NULL,
  `comment_id` BIGINT(20) NOT NULL,
  `dataset_id` BIGINT(20) NOT NULL,
  `is_default` TINYINT(1) NULL DEFAULT '0',
  PRIMARY KEY (field_id, comment_id)
)
  ENGINE = InnoDB;

-- (table) comments
CREATE TABLE comments (
  `id`           INT(11) AUTO_INCREMENT                                                                       NOT NULL,
  `text`         TEXT CHARACTER SET utf8                                                                      NOT NULL,
  `user_id`      INT(11)                                                                                      NOT NULL,
  `dataset_id`   INT(11)                                                                                      NOT NULL,
  `created`      DATETIME                                                                                     NULL,
  `modified`     DATETIME                                                                                     NULL,
  `comment_type` ENUM('Description', 'Grain', 'Partition', 'ETL Schedule', 'DQ Issue', 'Question', 'Comment') NULL,
  PRIMARY KEY (id),
  KEY `user_id` (`user_id`) USING BTREE,
  KEY `dataset_id` (`dataset_id`) USING BTREE,
  FULLTEXT KEY `fti_comment` (`text`)
)
  ENGINE = InnoDB
  CHARACTER SET latin1
  COLLATE latin1_swedish_ci
  AUTO_INCREMENT = 0;

-- field comments
CREATE TABLE `field_comments` (
  `id`                     INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`                INT(11)          NOT NULL,
  `comment`                VARCHAR(4000)    NOT NULL,
  `created`                DATETIME         NOT NULL,
  `modified`               TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `comment_crc32_checksum` INT(11) UNSIGNED          NULL COMMENT '4-byte CRC32',
  PRIMARY KEY (`id`),
  KEY `comment_key` (`comment`(100)),
  FULLTEXT KEY `fti_comment` (`comment`)
)
  ENGINE = InnoDB
  AUTO_INCREMENT = 0
  DEFAULT CHARSET = utf8;
