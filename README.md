Genbank ID checker/converter API
================================

__DOWN FOR NOW - MAY BRING BACK UP LATER, NOT A LOT OF USE, AND KINDA PRICY__

API Status: [http://recology.info/gbidsstatus](http://recology.info/gbidsstatus) ([source for status page](https://github.com/sckott/gbidsstatus))

API Docs: [http://recology.info/gbidsdocs/](http://recology.info/gbidsdocs/) (in progress)

## Under the hood

* API: Ruby/Sinatra
* Storage: MySQL
* Caching: Redis
  * each key cached for 3 hours
* Server: Caddy
  * https
* Authentication: none


Will soon have a cron job update when new dump is available every Sunday, but for now we're about a month behind the current dump of identifiers.

## base url

[https://gbids.xyz](https://gbids.xyz)

## API Endpoints

* `/` re-routes to `/heartbeat`
* `/heartbeat` - list routes
* `/acc` - `GET` - list accession ids
* `/acc/:id,:id,...` - `GET` - submit many accession numbers, get back boolean (match or no match)
* `/acc` - `POST`
* `/gi` - `GET` - list gi numbers
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
