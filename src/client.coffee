do (Websocket = window.WebSocket || window.MozWebSocket) ->
  # __opts__ is replaced with reload config
  # before this script is served to client
  opts = __opts__

  initializeReload = (afterDisconnect = false) ->
    connection = new WebSocket("ws://#{document.domain}:#{opts.reload}/")

    connection.onmessage = (msg) ->
      return refresh() if msg.data == 'refresh'
      location.reload()

    connection.onclose = ->
      initializeReload true

    connection.onopen = ->
      location.reload() if afterDisconnect and opts.reloadAfterReconnect

  refreshStylesheets = () ->
    for el in document.querySelectorAll('link[rel="stylesheet"]')
      unless el.getAttribute('data-href-origin')?
        el.setAttribute('data-href-origin', el.getAttribute('href'))
      el.setAttribute 'href', el.getAttribute('data-href-origin') + '?' + Date.now()

  initializeReload()
