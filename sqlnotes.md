# move genbank file to server
scp -i ~/usdaplantsapi.pem GbAccList.0207.2016.gz ubuntu@52.32.65.60:~/ncbi

# uncompress
gunzip GbAccList.0207.2016.gz

# create database
<!--
sudo mysql  -p
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
## locally
# LOAD DATA LOCAL INFILE '/Volumes/MacExtHD/ncbi/data.txt' INTO TABLE data COLUMNS TERMINATED BY ',';
## on server
LOAD DATA LOCAL INFILE '/home/ubuntu/ncbi/data.txt' INTO TABLE data COLUMNS TERMINATED BY ',';
ALTER TABLE `data` ADD INDEX `gi` (`gi`);
-->

# cleanup mysql interal files to free disk space
## from http://stackoverflow.com/a/26669243/1091766
sudo rm /var/lib/mysql/ibdata1
sudo rm /var/lib/mysql/ib_logfile0
sudo rm /var/lib/mysql/ib_logfile1

# expand a volume
http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-expand-volume.html

# mysql dump, if needed
sudo mysqldump -p gbids > gbids-backup-2016-03-15.sql

# load dump file
mysql gbids < gbids-dump-2016-03-21.sql
