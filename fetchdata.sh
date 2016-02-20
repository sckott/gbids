#/bin/bash

date=${1-1000}
echo ">> Downloading data for $date"
wget ftp://ftp.ncbi.nlm.nih.gov/genbank/livelists/GbAccList.0207.2016.gz

echo ">> clipping data subset"
head -n $n GbAccList.0207.2016 > gbsmall.txt
echo ">> in Ruby, preparing data to pipe to Redis"
ruby dataprep.rb
echo '>> unix2dos'
unix2dos gbsmall2.txt
echo '>> piping into Redis'
cat gbsmall2.txt | redis-cli --pipe
echo '>> cleaning up'
rm gbsmall.txt gbsmall2.txt

echo ">>$date IDs now in Redis :)"
