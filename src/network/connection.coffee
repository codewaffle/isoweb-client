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

  send: (obj) ->
    @conn.send(JSON.stringify(obj, replacer))
