texdec = new TextDecoder('utf-8')

class PacketReader
  setBuffer: (@buffer) ->
    @dv = new DataView(buffer)
    @pos = 0

  readString: ->
    len = @dv.getUint8(@pos)
    slice = @buffer.slice(@pos+1, @pos+1+len)
    @pos += 1+len
    return texdec.decode(slice)

  readUint32: ->
    val = @dv.getUint32(@pos)
    @pos += 4
    return val

  readUint16: ->
    val = @dv.getUint16(@pos)
    @pos += 2
    return val

  readUint8: ->
    val = @dv.getUint8(@pos)
    @pos += 1
    return val

  readFloat32: ->
    val = @dv.getFloat32(@pos)
    @pos += 4
    return val


module.exports =
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
    name,
    nameBuf = dv.buffer.slice(offset+1, offset+1+nameLen)
    name = texdec.decode(nameBuf)
    console.log nameLen, name

  handleInfo: (dv, offset) ->
    # server has sent us info
    nameLen = dv.getUint8(offset)
    nameBuf = dv.buffer.slice(offset+1, offset+1+nameLen)
    name = texdec.decode(nameBuf)

    # ugh, now we need to receive all properties..