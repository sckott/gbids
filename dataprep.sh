#/bin/bash

n=${1-1000}
echo ">> Setting output to $n - pass a number to change it"

echo ">> clipping data subset"
head -n $n GbAccList.0207.2016 > gbsmall.txt
echo ">> in Ruby, preparing data to pipe to Redis"
ruby dataprep.rb
echo '>> unix2dos'
unix2dos accdat.txt gidat.txt
echo '>> piping into Redis'
cat accdat.txt | redis-cli -p 6379 --pipe
cat gidat.txt | redis-cli -p 6380 --pipe
echo '>> cleaning up'
rm gbsmall.txt accdat.txt gidat.txt

echo ">>$n IDs now in Redis :)"
