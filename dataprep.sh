#/bin/bash

n=${1-1000}
echo ">> Setting output to $n - pass a number to change it"

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

echo ">>$n IDs now in Redis :)"
