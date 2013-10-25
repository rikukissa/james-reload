do (Websocket = window.WebSocket || window.MozWebSocket) ->
  # __opts__ is replaced with reload config
  # before this script is served to client
  opts = __opts__

  initializeReload = (afterDisconnect = false) ->
    connection = new WebSocket("ws://#{document.domain}:#{opts.proxyPort}/")

    connection.onmessage = (msg) ->
      return refreshStylesheets() if msg.data == 'refresh'
      location.reload()

    connection.onclose = ->
      initializeReload true

    connection.onopen = ->
      location.reload() if afterDisconnect and opts.reloadAfterReconnect

  refreshStylesheets = () ->
    for el in document.querySelectorAll('link[rel="stylesheet"]')
      unless el.getAttribute('data-href-origin')?
        el.setAttribute('data-href-origin', el.getAttribute('href'))

      copy = el.cloneNode true

      copy.onload = ->
        el.parentNode.removeChild el
      copy.onerror = ->
        el.parentNode.removeChild copy

      copy.setAttribute 'href', el.getAttribute('data-href-origin') + '?' + Date.now()

      el.parentNode.appendChild copy

  initializeReload()
  console.log 'lol'
