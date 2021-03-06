main = require '../main'
clock = require '../clock'

packetTypes = require './packet_types'
packetHandlers = require './packet_handlers'

PacketReader = require './packet_reader'
packet = new PacketReader()

module.exports = class Connection
  constructor: (@endpoint) ->
    @online = false
    @connWindow = main.windowManager.createWindow('connect')
    @connWindow.domElement.innerHTML = '<div class="spinner right">Connecting to server ...</div>'
    @connWindow.show().center()

    @conn = new WebSocket(@endpoint)
    @conn.binaryType = 'arraybuffer'
    me = @

    @conn.onopen = ->
      main.windowManager.closeWindow(me.connWindow)
      me.requestTimeSync()
      me.online = true

    @conn.onmessage = (evt) =>
      @onMessage(evt)
    @outgoingSync = []

  onMessage: (evt) ->
    packet.setBuffer(evt.data)

    pt = packet.getType()

    while pt > 0
      switch pt
        when packetTypes.PONG then @handleTimeSync(packet)
        when packetTypes.DO_ASSIGN_CONTROL then packetHandlers.handleAssignControl(@, packet)
        when packetTypes.ENTITYDEF_UPDATE then packetHandlers.handleEntityDefUpdate(@, packet)
        when packetTypes.ENTITY_UPDATE then packetHandlers.handleEntityUpdate(@, packet)
        when packetTypes.CMD_MENU_REQ_ENTITY then packetHandlers.handleEntityMenu(@, packet)
        when packetTypes.ENTITY_ENABLE then packetHandlers.handleEntityEnable(@, packet)
        when packetTypes.ENTITY_DISABLE then packetHandlers.handleEntityDisable(@, packet)
        when packetTypes.ENTITY_DESTROY then packetHandlers.handleEntityDestroy(@, packet)
        when packetTypes.CONTAINER_UPDATE then packetHandlers.handleContainerUpdate(@, packet)
        when packetTypes.CONTAINER_SHOW then packetHandlers.handleContainerShow(@, packet)
        when packetTypes.CONTAINER_HIDE then packetHandlers.handleContainerHide(@, packet)
        when packetTypes.MESSAGE then packetHandlers.handleMessage(@, packet)
        else console.log 'UNKNOWN PACKET', pt, evt.data
      pt = packet.getType()

  sendBinary: (data) ->
    if @conn.readyState != 1
      window.location.reload(true)
    @conn.send(data)

  # what a mess.. most of this should either be in clock or most of clock should be here.
  requestTimeSync: () ->
    time_req = new DataView(new ArrayBuffer(3))
    now = Date.now() / 1000.0
    num = Math.floor(Math.random() * 65536.0)

    time_req.setUint8(0, packetTypes.PING)
    time_req.setUint16(1, num)

    # t0
    @outgoingSync[num] = now
    @sendBinary(time_req.buffer)

    setTimeout((=> @requestTimeSync()), 500)

  handleTimeSync: (packet) ->
    num = packet.readUint16()
    t0 = @outgoingSync[num]
    t1 = packet.readFloat64()
    t2 = packet.timestamp
    t3 = Date.now() / 1000.0

    clock.ntp_sync(t0, t1, t2, t3)
