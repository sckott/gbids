Genbank ID checker/converter API
================================

Right now setup to load Genbank accession numbers into Redis, and provides an API to match accession numbers against the in memory data.

## Under the hood

Using Ruby/Sinatra to make the API itself. Accession id's are stored directly in Redis, in memory. Haven't sorted out yet whether we can actually store all ~650 million or so identifiers, and then there's the GI numbers as well, could be a different route on the API. If we can store all data in memory, this should be super fast, if not, will pursue another approach.

## base url

[http://52.33.101.178:8877](http://52.33.101.178:8877)

## API Endpoints

* `/` re-routes to `/heartbeat`
* `/heartbeat` - list routes
* `/acc/:id,:id,...` - `GET` - submit many accession numbers, get back boolean (match or no match)
* `/acc` - `POST`
* `/gi/:id,:id,...` - `GET` - submit many gi numbers, get back boolean (match or no match)
* `/gi` - `POST`
* `/acc2gi/:id,:id,...` - `GET` - get gi numbers from accession numbers
* `/acc2gi` - `POST`
* `/gi2acc/:id,:id,...` - `GET` - get accession numbers from gi numbers
* `/gi2acc` - `POST`
* `/random/acc?n=` get a set of random accession numbers
* `/random/gi?n=` get a set of random gi numbers

## start

start Redis

```
sudo redis-server /etc/redis-6379.conf
sudo redis-server /etc/redis-6380.conf
```

Load data

> requires downloading data from NCBI FTP server first...takes a while. Once you have the unzipped file:

```
sh dataprep.sh 1000
```

where the `100` is the number of keys (accession numbers) to input into Redis. Tried up to 10 million so far on my macbook pro with 8 GB, works fine. Dumping to disk from 10 million keys gives ~ 164 mb `dump.rdb` file

```
hub clone sckott/gbcheck && cd gbcheck
unicorn -c unicorn.conf -D
```

## Example

using [curl](https://curl.haxx.se/) and [jq](https://stedolan.github.io/jq/)

```
curl 'http://52.33.101.178:8877/heartbeat' | jq .
#> {
#>   "routes": [
#>     "/heartbeat",
#>     "/acc/:accessions (GET)",
#>     "/acc (POST)",
#>     "/gi/:gi_numbers (GET)",
#>     "/gi (POST)",
#>     "/acc2gi/:accessions (GET)",
#>     "/acc2gi (POST)",
#>     "/gi2acc/:gi_numbers (GET)",
#>     "/gi2acc (POST)",
#>     "/random/acc?n=",
#>     "/random/gi?n="
#>   ]
#> }
```

```
curl 'http://52.33.101.178:8877/acc/AACY024124486,AACY024124483,asdfd,asdf,AACY024124476' | jq .
#> {
#>   "AACY024124486": true,
#>   "AACY024124483": true,
#>   "asdfd": false,
#>   "asdf": false,
#>   "AACY024124476": true
#> }
```

```
curl -XPOST 'http://52.33.101.178:8877/acc' -F ids='AACY024124486,AACY024124483,asdfd,asdf,AACY024124476' | jq .
#> {
#>   "AACY024124486": true,
#>   "AACY024124483": true,
#>   "asdfd": false,
#>   "asdf": false,
#>   "AACY024124476": true
#> }
```

```
curl 'http://52.33.101.178:8877/acc2gi/AACY024124486,AACY024124483,asdfd,asdf,AACY024124476' | jq .
#> {
#>   "AACY024124486": "129566184",
#>   "AACY024124483": "129566187",
#>   "asdfd": null,
#>   "asdf": null,
#>   "AACY024124476": "129566194"
#> }
```

```
curl 'http://52.33.101.178:8877/random/gi?n=2' | jq .
#> [
#>   "129566380",
#>   "129566565"
#> ]
```

```
curl 'http://52.33.101.178:8877/random/acc?n=2' | jq .
#> [
#>   "AACY024123704",
#>   "AACY024123612"
#> ]
```

## todo

* ...
