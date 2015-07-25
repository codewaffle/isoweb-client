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

    pt = packet.getType()

    while pt > 0
      switch pt
        when packetTypes.PONG then @handleTimeSync(packet)
        when packetTypes.DO_ASSIGN_CONTROL then packetHandlers.handleAssignControl(packet)
        when packetTypes.ENTITY_UPDATE then packetHandlers.handleEntityUpdate(packet)
        else console.log 'UNKNOWN PACKET', packetType, evt.data
      pt = packet.getType()

  sendBinary: (data) ->
    if @conn.readyState != 1
      window.location.reload(true)
    @conn.send(data)

  # what a mess.. most of this should either be in clock or most of clock should be here.
  requestTimeSync: (count) ->
    if not count?
      clock.reset_latency()
      count = 0

    time_req = new DataView(new ArrayBuffer(4))
    now = Date.now() / 1000.0
    num = Math.floor(Math.random() * 65536.0)

    time_req.setUint8(0, packetTypes.PING)
    time_req.setUint16(1, num)

    # t0
    @outgoingSync[num] = now
    @sendBinary(time_req.buffer)

    if count < 10
      setTimeout((=> @requestTimeSync(count+1)), 200)
    else
      clock.calculate_latency()

  handleTimeSync: (packet) ->
    num = packet.readUint16()
    t0 = @outgoingSync[num]
    t1 = packet.readFloat64()
    t2 = packet.timestamp
    t3 = Date.now() / 1000.0

    clock.ntp_sync(t0, t1, t2, t3)
