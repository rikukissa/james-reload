# James-reload
Browser reload plugin for [James.js](https://github.com/leonidas/james.js)

## Requirements
* Node.js
* NPM

## Installation
    npm install -g james-reload

## Binary
    jreload -s <source port> -p <port to proxy to> -w <list of globs to watch>
Example

    jreload -s 9001 -p 9002 -w js/**/*.js,js/**/*.hbs

More information

    jreload --help


## API
__Basic configuration__
```javascript
var reloadFactory = require('james-reload');
var reload = reloadFactory({
  srcPort: 80,
  proxyPort: 9002
});
```
Reads content from port __80__ and proxies it to port __9002__ with the client side script appended

__Example usage__
```javascript
var reloadFactory = require('james-reload');
var reload = reloadFactory({
  srcPort: 80,
  proxyPort: 9002
});

setTimeout(function() {
  reload();
}, 5000)

```

Reloads your browsers location after 5 seconds.

---

## reloadFactory(config)
Returns a function [reload](#reload) for sending a signal when client should reload content
####config (Object)
* srcPort: (Number)
    * Port to read from
    * Default: __9001__
* proxyPort: (Number)
    * Proxy where the content is proxied
    * Default: __9002__
* keepReconnecting (Boolean)
    * Try reconnection if proxy request fails
    * Default: __true__
* reloadAfterReconnect
    * Reload client location when websocket connection disconnects and connects again
    * Default: __true__
* debug
    * console.log errors and info messages
    * Default: __false__

# reload(config)
signals client script to reload content
####config (Object)
* stylesheetsOnly: (Boolean)
    * Tell client script to only reload stylesheet files if set to true
    * Default: __false__
