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

  onMessage: (evt) ->
    packet.setBuffer(evt.data)
    packetType = packet.readUint16(0)

    switch packetType
      when packetTypes.ENTITY_UPDATE then packetHandlers.handleEntityUpdate(packet)
      else console.log 'UNKNOWN PACKET', packetType, evt.data

  sendBinary: (data) ->
    @conn.send(data)
