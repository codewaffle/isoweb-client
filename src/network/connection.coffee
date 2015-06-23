packetTypes = require '../packet_types'

replacer = (k, v) ->
  if v.toFixed?
    return Number(v.toFixed(3))
  return v

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

    if packetType == packetTypes.ISLAND_UPDATE
      islandId = dv.getUint32(2)
      entCount = dv.getUint16(6)

      for entIdx in [8...8+(entCount*16)] by 16
        entId = dv.getUint32(entIdx)
        entPosX = dv.getFloat32(entIdx+4)
        entPosY = dv.getFloat32(entIdx+8)
        entBear = dv.getFloat32(entIdx+12)
        console.log entIdx, entPosX, entPosY, entBear

      console.log islandId, entCount

  sendBinary: (data) ->
    @conn.send(data)

  sendMoveTo: (x, y) ->
    @sendMoveToPacket.setFloat32(2, x)
    @sendMoveToPacket.setFloat32(6, y)
    @sendBinary(@sendMoveToPacket.buffer)