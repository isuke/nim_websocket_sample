import websocket, asynchttpserver, asyncnet, asyncdispatch

var
  server = newAsyncHttpServer()
  singletonWs {.global.}: Future[tuple[ws: AsyncWebSocket, error: string]]

proc createWs(req: Request): Future[tuple[ws: AsyncWebSocket, error: string]] =
  if singletonWs.isNil:
    singletonWs = verifyWebsocketRequest(req, "myfancyprotocol")
    return singletonWs
  else:
    return singletonWs

proc cb(req: Request) {.async.} =

  let (ws, error) = waitfor createWs(req)
  # let (ws, error) = await verifyWebsocketRequest(req, "myfancyprotocol")
  if ws.isNil:
    echo "WS negotiation failed: ", error
    await req.respond(Http400, "Websocket negotiation failed: " & error)
    req.client.close()
  else:
    echo "New websocket customer arrived!"
    while true:
      echo "---------------------------------------------"
      try:
        var f = await ws.readData()
        echo "receive date: ", f.data

        if f.opcode == Opcode.Text:
          echo "receive date: ", f.data
          waitFor ws.sendText(f.data, masked = false)

      except:
        echo "---------------------------------------------"
        echo getCurrentExceptionMsg()
        break

  discard ws.close()
  echo ".. socket went away."

waitfor server.serve(Port(8080), cb)
