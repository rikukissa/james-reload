var server;

server = function(opts) {
  var WebSocketServer, appendScript, client, connections, fs, http, reload, wsServer;
  fs = require('fs');
  http = require('http');
  WebSocketServer = require('websocket').server;
  client = fs.readFileSync(__dirname + '/client.js');
  appendScript = function(content) {
    return content.replace('</body>', "<script>" + (client.toString()) + "</script></body>");
  };
  server = http.createServer(function(request, response) {
    var proxyReq;
    proxyReq = http.request({
      hostname: "localhost",
      port: opts.proxy,
      method: request.method,
      path: request.url,
      headers: request.headers
    }, function(proxyRes) {
      var content, html;
      html = proxyRes.headers['content-type'].indexOf("text/html") > -1;
      content = "";
      proxyRes.on('data', function(chunk) {
        if (!html) {
          return response.write(chunk, 'binary');
        }
        return content += chunk;
      });
      proxyRes.on('end', function() {
        if (html) {
          return response.end(appendScript(content), 'binary');
        }
        return response.end();
      });
      if (!html) {
        return response.writeHead(proxyRes.statusCode, proxyRes.headers);
      }
    });
    return proxyReq.end();
  });
  server.listen(opts.reload);
  wsServer = new WebSocketServer({
    httpServer: server,
    autoAcceptConnections: false
  });
  connections = [];
  wsServer.on("request", function(request) {
    var connection;
    connection = request.accept(null, request.origin);
    connections.push(connection);
    return connection.on("close", function() {
      return connections.splice(connections.indexOf(connection), 1);
    });
  });
  reload = function(refreshOnly) {
    var connection, _i, _len, _results;
    if (refreshOnly == null) {
      refreshOnly = false;
    }
    _results = [];
    for (_i = 0, _len = connections.length; _i < _len; _i++) {
      connection = connections[_i];
      _results.push(connection.sendUTF((refreshOnly ? 'refresh' : 'reload')));
    }
    return _results;
  };
  return reload;
};

module.exports = server;
