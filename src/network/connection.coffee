packetTypes = require './packet_types'
packetHandlers = require './packet_handlers'

PacketReader = require './packet_reader'
packet = new PacketReader()

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
    packet.setBuffer(evt.data)
    packetType = packet.readUint16(0)

    switch packetType
      when packetTypes.ISLAND_UPDATE then packetHandlers.handleIslandUpdate(packet)
      when packetTypes.SPAWN then packetHandlers.handleSpawn(packet)
      when packetTypes.INFO then packetHandlers.handleInfo(packet)
      else console.log 'UNKNOWN PACKET', packetType, evt.data

  sendBinary: (data) ->
    @conn.send(data)

  sendMoveTo: (x, y) ->
    @sendMoveToPacket.setFloat32(2, x)
    @sendMoveToPacket.setFloat32(6, y)
    @sendBinary(@sendMoveToPacket.buffer)