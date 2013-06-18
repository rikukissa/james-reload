
server = (opts) ->
  
  fs        = require 'fs'
  http      = require 'http'

  WebSocketServer = require('websocket').server
  client = fs.readFileSync __dirname + '/client.js'
  
  appendScript = (html) ->
    html.replace '</body>', "<script>#{client.toString()}</script></body>"

  server = http.createServer (request, response) ->
    html = ""

    proxyReq = http.request
      hostname: "localhost"
      port: opts.proxy
      method: request.method
      path: request.url
    , (proxyRes) ->
      proxyRes.on 'data', (chunk) -> html += chunk
      proxyRes.on 'end', ->
        response.end appendScript(html), 'binary'

    proxyReq.end()
  
  server.listen opts.reload

  wsServer = new WebSocketServer
    httpServer: server
    autoAcceptConnections: false
  
  connections = []

  wsServer.on "request", (request) ->
    connection = request.accept(null, request.origin)
    connections.push connection
    connection.on "close", () ->
      connections.splice connections.indexOf(connection), 1

  reload = (refreshOnly = false) ->
    for connection in connections
      connection.sendUTF (if refreshOnly then 'refresh' else 'reload') 

  return reload

module.exports = server

