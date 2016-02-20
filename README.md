Genbank ID checker API
======================

Right now setup to load Genbank accession numbers into Redis, and provides an API to match accession numbers against the in memory data.

## Under the hood

Configuration might change, but right now using [webdis](http://webd.is/), a JSON API to a running Redis instance. Using Ruby/Sinatra to make the API itself. Accession id's are stored directly in Redis, in memory. Haven't sorted out yet whether we can actually store all ~650 million or so identifiers, and then there's the GI numbers as well, could be a different route on the API. If we can store all data in memory, this should be super fast, if not, will pursue another approach.

## API Endpoints

* `/` re-routes to `/heartbeat`
* `/heartbeat` - list routes
* `/match/:id,:id,...` - only `GET` for now. submit many accession numbers, get back boolean (match or no match)

## start

start Redis

```
redis-server
```

start Webdis

```
webdis &
```

Load data

> requires downloading data from NCBI FTP server first...takes a while. Once you have the unzipped file:

```
sh dataprep.sh 100
```

where the `100` is the number of keys (accession numbers) to input into Redis. Tried up to 10 million so far on my macbook pro with 8 GB, works fine. Dumping to disk from 10 million keys gives ~ 164 mb `dump.rdb` file

```
hub clone sckott/gbcheck
cd gbcheck
unicorn -p 8888
```

## Example

```
curl 'http://localhost:8888/heartbeat' | jq .
#> {
#>   "routes": [
#>     "/match/:identifier",
#>     "/heartbeat"
#>   ]
#> }
```

```
curl 'http://localhost:8888/match/AACY024124486,AACY024124483,asdfd,asdf,AACY024124476'
#> {
#>   "AACY024124486": true,
#>   "AACY024124483": true,
#>   "asdfd": false,
#>   "asdf": false,
#>   "AACY024124476": true
#> }
```

```
curl -XPOST 'http://localhost:8888/match' -F ids='AACY024124486,AACY024124483,asdfd,asdf,AACY024124476' | jq .
#> {
#>   "AACY024124486": true,
#>   "AACY024124483": true,
#>   "asdfd": false,
#>   "asdf": false,
#>   "AACY024124476": true
#> }
```

## todo

* probably dont need webdis, just fun to play with
