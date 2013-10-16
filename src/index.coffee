module.exports = (opts = {}) ->
  fs        = require 'fs'
  http      = require 'http'
  wsServer  = require('websocket').server
  colors    = require 'colors'

  opts.proxyPort = opts.proxyPort or opts.proxy or 9002
  opts.srcPort = opts.srcPort or opts.reload or 9001
  opts.keepReconnecting = opts.keepReconnecting or true
  opts.reloadAfterReconnect = opts.reloadAfterReconnect or true
  opts.debug = opts.debug or false

  clientScript = fs.readFileSync(__dirname + '/client.js')
    .toString().replace '__opts__', JSON.stringify opts

  appendScript = (html) ->
    html.replace '</body>', "<script>#{clientScript}</script></body>"

  log = (args...)->
    console.log.apply console, ['James-reload:'].concat args

  server = http.createServer (request, response) ->
    createRequest = ->
      proxyReq = http.request
        hostname: "localhost"
        port: opts.proxyPort
        method: request.method
        path: request.url
        headers: request.headers
      , (proxyRes) ->

        contentType = proxyRes.headers['content-type']
        isHTML = contentType?.toLowerCase().indexOf("text/html") > -1
        htmlData = ""

        proxyRes.on 'data', (chunk) ->
          return response.write chunk, 'binary' unless isHTML
          htmlData += chunk

        proxyRes.on 'end', ->
          return response.end appendScript(htmlData), 'utf-8' if isHTML
          response.end()

        response.writeHead proxyRes.statusCode, proxyRes.headers unless isHTML

      request.on 'data', (data) ->
        proxyReq.write(data)

      request.on 'end', ->
       proxyReq.end()

      proxyReq.on 'error', (e) ->
        log 'Proxy request failed:'.red, e.message

        if opts.keepReconnecting
          log 'Reconnecting'.yellow
          createRequest()

    createRequest()

  server.listen opts.srcPort

  wsServer = new wsServer
    httpServer: server
    autoAcceptConnections: false

  connections = []

  wsServer.on "request", (request) ->
    connection = request.accept(null, request.origin)
    connections.push connection
    connection.on "close", () ->
      connections.splice connections.indexOf(connection), 1

  reload = (opts = {}) ->
    opts.stylesheetsOnly = opts.stylesheetsOnly or false

    signal = if opts.stylesheetsOnly then 'refresh' else 'reload'

    for connection in connections
      connection.sendUTF signal

    log signal.green

  return reload



