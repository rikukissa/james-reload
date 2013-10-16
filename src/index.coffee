module.exports = (opts) ->
  fs        = require 'fs'
  http      = require 'http'

  WebSocketServer = require('websocket').server

  clientScript = fs.readFileSync(__dirname + '/client.js')
    .toString().replace '__opts__', JSON.stringify opts

  appendScript = (html) ->
    html.replace '</body>', "<script>#{clientScript}</script></body>"

  server = http.createServer (request, response) ->
    createRequest = ->
      proxyReq = http.request
        hostname: "localhost"
        port: opts.proxy || opts.proxyPort
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

      proxyReq.on 'error', createRequest

    createRequest()

  server.listen opts.reload || opts.srcPort

  wsServer = new WebSocketServer
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

    for connection in connections
      connection.sendUTF (if opts.stylesheetsOnly then 'refresh' else 'reload')

  return reload



