#/bin/bash

echo ">> Downloading data"
wget ftp://ftp.ncbi.nlm.nih.gov/genbank/livelists/GbAccList.0207.2016.gz

echo ">> Uncompressing"
gunzip GbAccList.0207.2016.gz

echo ">> Done"
