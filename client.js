var connection;window.WebSocket=window.WebSocket||window.MozWebSocket,connection=new WebSocket("ws://localhost:9002/"),connection.onmessage=function(a){var b;return b=function(){var a,b,c,d,e;for(d=document.querySelectorAll('link[rel="stylesheet"]'),e=[],b=0,c=d.length;c>b;b++)a=d[b],null==a.getAttribute("data-href-origin")&&a.setAttribute("data-href-origin",a.getAttribute("href")),e.push(a.setAttribute("href",a.getAttribute("data-href-origin")+"?"+Date.now()));return e},"refresh"===a.data&&b(),"reload"===a.data?location.reload():void 0};