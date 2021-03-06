texdec = new TextDecoder('utf-8')

module.exports = class PacketReader
  setBuffer: (@buffer) ->
    @dv = new DataView(@buffer)
    @pos = 0

  getType: ->
    @type = @readUint8()

    if @type > 0
      @timestamp = @readFloat32()
      return @type

    return 0

  readSmallString: ->
    len = @dv.getUint8(@pos)
    slice = @buffer.slice(@pos+1, @pos+1+len)
    @pos += 1+len
    return texdec.decode(slice)

  readString: ->
    len = @dv.getUint16(@pos)
    slice = @buffer.slice(@pos+2, @pos+2+len)
    @pos += 2+len
    return texdec.decode(slice)

  readUint32: ->
    val = @dv.getUint32(@pos)
    @pos += 4
    return val

  readEntityId: ->
    # special cased because I intend on supporting more than 4 billion entities (including deleted entities)
    # I don't want to recycle ids. This will probably end up as 2 ints, with the 1st int indicating what made the item.
    return @readUint32()

  readHash64: ->
    return [@readUint32().toString(16),@readUint32().toString(16)].join('/')

  readUint16: ->
    val = @dv.getUint16(@pos)
    @pos += 2
    return val

  readUint8: ->
    val = @dv.getUint8(@pos)
    @pos += 1
    return val

  readChar: ->
    return String.fromCharCode(@readUint8())

  readFloat32: ->
    val = @dv.getFloat32(@pos)
    @pos += 4
    return val

  readFloat64: ->
    val = @dv.getFloat64(@pos)
    @pos += 8
    return val

