Genbank ID checker/converter API
================================

Right now setup to load Genbank accession numbers into Redis, and provides an API to match accession numbers against the in memory data.

## Under the hood

Using Ruby/Sinatra to make the API itself. Accession id's are stored directly in Redis, in memory. Haven't sorted out yet whether we can actually store all ~650 million or so identifiers, and then there's the GI numbers as well, could be a different route on the API. If we can store all data in memory, this should be super fast, if not, will pursue another approach.

## base url

[https://gbids.xyz](https://gbids.xyz)

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

## start

start Redis

```
sudo redis-server /etc/redis-6379.conf
```

Load data

* downloading data from NCBI FTP server first...takes a while
* uncompress files
* mysql stuff...

## Example

using [curl](https://curl.haxx.se/) and [jq](https://stedolan.github.io/jq/)

```
curl 'https://gbids.xyz/heartbeat' | jq .
{
  "routes": [
    "/heartbeat",
    "/acc/:accessions (GET)",
    "/acc (POST)",
    "/gi/:gi_numbers (GET)",
    "/gi (POST)",
    "/acc2gi/:accessions (GET)",
    "/acc2gi (POST)",
    "/gi2acc/:gi_numbers (GET)",
    "/gi2acc (POST)"
  ]
}
```

```
curl 'https://gbids.xyz/acc/AACY024124486,AACY024124483,asdfd,asdf,AACY024124476' | jq .
{
  "matched": 3,
  "returned": 5,
  "data": {
    "AACY024124486": true,
    "AACY024124483": true,
    "asdfd": false,
    "asdf": false,
    "AACY024124476": true
  },
  "error": null
}
```

```
curl -XPOST 'https://gbids.xyz/acc' -F ids='AACY024124486,AACY024124483,asdfd,asdf,AACY024124476' | jq .
{
  "matched": 3,
  "returned": 5,
  "data": {
    "AACY024124486": true,
    "AACY024124483": true,
    "asdfd": false,
    "asdf": false,
    "AACY024124476": true
  },
  "error": null
}
```

```
curl 'https://gbids.xyz/gi/129566194,129566187,129566184,asdfafd' | jq .
{
  "matched": 3,
  "returned": 4,
  "data": {
    "129566194": true,
    "129566187": true,
    "129566184": true,
    "asdfafd": false
  },
  "error": null
}
```

```
curl 'https://gbids.xyz/acc2gi/AACY024124486,AACY024124483,asdfd,asdf,AACY024124476' | jq .
{
  "matched": 3,
  "returned": 5,
  "data": [
    {
      "accession": "AACY024124476",
      "gi": 129566194
    },
    {
      "accession": "AACY024124483",
      "gi": 129566187
    },
    {
      "accession": "AACY024124486",
      "gi": 129566184
    },
    {
      "accession": "asdfd",
      "gi": null
    },
    {
      "accession": "asdf",
      "gi": null
    }
  ],
  "error": null
}
```

```
curl 'https://gbids.xyz/gi2acc/129566194,129566187,129566184' | jq .
{
  "matched": 3,
  "returned": 3,
  "data": [
    {
      "accession": "AACY024124486",
      "gi": 129566184
    },
    {
      "accession": "AACY024124483",
      "gi": 129566187
    },
    {
      "accession": "AACY024124476",
      "gi": 129566194
    }
  ],
  "error": null
}
```
