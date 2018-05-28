import websocket, asyncnet, asyncdispatch, locks

let ws = waitFor newAsyncWebsocketClient("localhost",
  Port 8080, "/?encoding=text", ssl = false, protocols = @["myfancyprotocol"])
echo "connected!"

var
  writerTHread: Thread[void]
  L: Lock

proc reader() {.async.} =
  while true:
    let read = await ws.readData()
    echo "read: ", read

proc writer() {.async, thread.} =
  while true:
    let read = await ws.readData()
    echo "read: ", read

proc ping() {.async.} =
  while true:
    await sleepAsync(6000)
    echo "ping"
    await ws.sendPing(masked = true)

initLock(L)

createThread(writerTHread, writer)

asyncCheck reader()
asyncCheck ping()
runForever()
