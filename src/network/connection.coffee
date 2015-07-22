clock = require '../clock'

packetTypes = require './packet_types'
packetHandlers = require './packet_handlers'

PacketReader = require './packet_reader'
packet = new PacketReader()

module.exports = class Connection
  constructor: (@endpoint) ->
    @conn = new WebSocket(@endpoint)
    @conn.binaryType = 'arraybuffer'
    me = @

    @conn.onopen = ->
      me.requestTimeSync()

    @conn.onmessage = (evt) =>
      @onMessage(evt)
    @outgoingSync = []

  onMessage: (evt) ->
    packet.setBuffer(evt.data)

    switch packet.type
      when packetTypes.PONG then @handleTimeSync(packet)
      when packetTypes.ENTITY_UPDATE then packetHandlers.handleEntityUpdate(packet)
      else console.log 'UNKNOWN PACKET', packetType, evt.data

  sendBinary: (data) ->
    @conn.send(data)

  requestTimeSync: () ->
    time_req = new DataView(new ArrayBuffer(4))
    now = window.performance.now() / 1000.0
    num = Math.floor(Math.random() * 65536.0)

    time_req.setUint16(0, packetTypes.PING)
    time_req.setUint16(2, num)

    # t0
    @outgoingSync[num] = now
    @sendBinary(time_req.buffer)
    setTimeout((=> @requestTimeSync()), 15000)

  handleTimeSync: (packet) ->
    num = packet.readUint16()
    t0 = @outgoingSync[num]
    t1 = packet.readFloat64()
    t2 = packet.timestamp
    t3 = window.performance.now() / 1000.0

    clock.ntp_sync(t0, t1, t2, t3)
