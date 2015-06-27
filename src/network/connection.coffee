packetTypes = require './packet_types'

replacer = (k, v) ->
  if v.toFixed?
    return Number(v.toFixed(3))
  return v

texdec = new TextDecoder('utf-8')

module.exports = class Connection
  constructor: (@endpoint) ->
    @conn = new WebSocket(@endpoint)
    @conn.binaryType = 'arraybuffer'

    @conn.onmessage = (evt) =>
      @onMessage(evt)

    @sendMoveToPacket = new DataView(new ArrayBuffer(10))

    # packet header is constant
    @sendMoveToPacket.setUint16(0, packetTypes.MOVE_TO)

  handleIslandUpdate: (dv, offset) ->
    islandId = dv.getUint32(offset)
    entCount = dv.getUint16(offset+4)

    for entIdx in [offset...offset+(entCount*16)] by 16
      entId = dv.getUint32(entIdx)
      entPosX = dv.getFloat32(entIdx+4)
      entPosY = dv.getFloat32(entIdx+8)
      entBear = dv.getFloat32(entIdx+12)
      console.log entIdx, entPosX, entPosY, entBear

    console.log islandId, entCount

  handleSpawn: (dv, offset) ->
    nameLen = dv.getUint8(offset)
    nameBuf = dv.buffer.slice(offset+1, offset+1+nameLen)
    name = texdec.decode(nameBuf)
    console.log nameLen, name

  onMessage: (evt) ->
    dv = new DataView(evt.data)
    packetType = dv.getUint16(0)

    switch packetType
      when packetTypes.ISLAND_UPDATE then @handleIslandUpdate(dv, 2)
      when packetTypes.SPAWN then @handleSpawn(dv, 2)
      else console.log 'UNKNOWN PACKET', packetType, evt.data

  sendBinary: (data) ->
    @conn.send(data)

  sendMoveTo: (x, y) ->
    @sendMoveToPacket.setFloat32(2, x)
    @sendMoveToPacket.setFloat32(6, y)
    @sendBinary(@sendMoveToPacket.buffer)