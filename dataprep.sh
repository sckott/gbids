#/bin/bash

n=${1-1000}
echo ">> Setting output to $n (default: 1000)"

echo ">> clipping data subset, then awking"
head -n $n GbAccList.0207.2016 \
	| cut -d, -f1,3 \
	| awk '{print "SET,"$0}' \
	| awk -F"," -v quote="\"" -v OFS="\" \"" '$1=$1 {print "\x22" $0 "\x22"}' \
	> accdat.txt

awk '{print $1,$3,$2}' accdat.txt > gidat.txt

echo '>> unix2dos'
unix2dos accdat.txt gidat.txt

echo '>> piping into Redis'
cat accdat.txt | redis-cli -p 6379 --pipe
cat gidat.txt | redis-cli -p 6380 --pipe

echo '>> cleaning up'
rm accdat.txt gidat.txt

echo ">>$n IDs now in Redis :)"

echo '>> done'


split -l 1000000 accdat.txt accchunks
for f in accchunks*; do redis-cli -p 6379 --pipe; done

# compress file
gzip GbAccList.0207.2016
