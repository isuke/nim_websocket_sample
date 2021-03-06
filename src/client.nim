import websocket, asyncnet, asyncdispatch

let ws = waitFor newAsyncWebsocketClient("localhost",
  Port 8080, "/?encoding=text", ssl = false, protocols = @["myfancyprotocol"])
echo "connected!"

proc reader() {.async.} =
  while true:
    let read = await ws.readData()
    echo "read: ", read

proc ping() {.async.} =
  while true:
    await sleepAsync(6000)
    echo "ping"
    await ws.sendPing(masked = true)

asyncCheck reader()
asyncCheck ping()
runForever()
