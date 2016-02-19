Gebank ID checker API
=====================

## Under the hood

Configuration might change, but right now using [webdis](http://webd.is/), a JSON API to a running Redis instance. Using Ruby/Sinatra to make the API itself. Accession id's are stored directly in Redis, in memory. Haven't sorted out yet whether we can actually store all ~650 million or so identifiers, and then there's the GI numbers as well, could be a different route on the API. If we can store all data in memory, this should be super fast, if not, will pursue another approach.

## API Endpoints

* `/` re-routes to `/heartbeat`
* `/heartbeat` - list routes
* `/match/:id,:id,...` - only `GET` for now. submit many accession numbers, get back boolean (match or no match)

## start

```
hub clone sckott/gbcheck
cd gbcheck
thin start
```

## Example

```
curl 'http://localhost:3000/heartbeat' | jq .
#> {
#>   "routes": [
#>     "/match/:identifier",
#>     "/heartbeat"
#>   ]
#> }
```

```
curl 'http://localhost:3000/match/AACY024124486,AACY024124483,asdfd,asdf,AACY024124476'
#> {
#>   "AACY024124486": true,
#>   "AACY024124483": true,
#>   "asdfd": false,
#>   "asdf": false,
#>   "AACY024124476": true
#> }
```
