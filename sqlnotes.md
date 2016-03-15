# create database
<!-- mysql
CREATE DATABASE gbids;
use gbids;
show tables;
-->

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
sudo mysql --local-infile -p
# sudo mysql --local-infile -p # on server
use gbids;
LOAD DATA LOCAL INFILE '/Volumes/MacExtHD/ncbi/data.txt' INTO TABLE data COLUMNS TERMINATED BY ',';
#LOAD DATA LOCAL INFILE '/home/ubuntu/ncbi/data.txt' INTO TABLE data COLUMNS TERMINATED BY ','; # on server
ALTER TABLE `data` ADD INDEX `gi` (`gi`);
-->

# cleanup mysql interal files to free disk space
http://stackoverflow.com/a/26669243/1091766

# expand a volume
http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-expand-volume.html