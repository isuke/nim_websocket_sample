import websocket, asyncnet, asyncdispatch

let ws = waitFor newAsyncWebsocketClient("localhost",
  Port 8080, "/?encoding=text", ssl = false, protocols = @["myfancyprotocol"])

echo "connected!"

proc writer() {.async.} =
  while true:
    write stdout, "write: "
    var text = readLine stdin
    await ws.sendText text

asyncCheck writer()
runForever()
