packetTypes = require './packet_types'
packetHandlers = require './packet_handlers'

module.exports = class Connection
  constructor: (@endpoint) ->
    @conn = new WebSocket(@endpoint)
    @conn.binaryType = 'arraybuffer'

    @conn.onmessage = (evt) =>
      @onMessage(evt)

    @sendMoveToPacket = new DataView(new ArrayBuffer(10))

    # packet header is constant
    @sendMoveToPacket.setUint16(0, packetTypes.MOVE_TO)

  onMessage: (evt) ->
    dv = new DataView(evt.data)
    packetType = dv.getUint16(0)

    switch packetType
      when packetTypes.ISLAND_UPDATE then packetHandlers.handleIslandUpdate(dv, 2)
      when packetTypes.SPAWN then packetHandlers.handleSpawn(dv, 2)
      when packetTypes.INFO then packetHandlers.handleInfo(dv, 2)
      else console.log 'UNKNOWN PACKET', packetType, evt.data

  sendBinary: (data) ->
    @conn.send(data)

  sendMoveTo: (x, y) ->
    @sendMoveToPacket.setFloat32(2, x)
    @sendMoveToPacket.setFloat32(6, y)
    @sendBinary(@sendMoveToPacket.buffer)