# create database
<!-- mysql
CREATE DATABASE gbids;
use gbids;
show tables; -->

# create table
<!-- DROP TABLE data; -->
<!-- TRUNCATE TABLE data; -->
CREATE TABLE data(
  accession     VARCHAR(20)        NOT NULL,
  seqver        TINYINT            NOT NULL,
  gi            INT                NOT NULL,
  PRIMARY KEY (accession)
);

# load data
<!--
sudo mysql --local-infile
use gbids;
LOAD DATA LOCAL INFILE '/Volumes/MacExtHD/ncbi/data.txt' INTO TABLE data COLUMNS TERMINATED BY ',';
ALTER TABLE `data` ADD INDEX `gi` (`gi`);
-->
