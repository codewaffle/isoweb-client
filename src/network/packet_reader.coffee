texdec = new TextDecoder('utf-8')

module.exports = class PacketReader
  setBuffer: (@buffer) ->
    @dv = new DataView(@buffer)
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