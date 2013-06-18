window.WebSocket = window.WebSocket || window.MozWebSocket
connection = new WebSocket('ws://localhost:9002/')
connection.onmessage = (msg) -> 
  refresh = () ->
    for el in document.querySelectorAll('link[rel="stylesheet"]')
      unless el.getAttribute('data-href-origin')?
        el.setAttribute('data-href-origin', el.getAttribute('href'))
      el.setAttribute 'href', el.getAttribute('data-href-origin') + '?' + Date.now()
  refresh() if msg.data == 'refresh'
  location.reload() if msg.data == 'reload'