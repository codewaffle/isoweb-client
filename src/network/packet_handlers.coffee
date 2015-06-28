module.exports =
  handleIslandUpdate: (pr) ->
    islandId = pr.readUint32()
    entCount = pr.readUint16()

    for entIdx in [0...entCount]
      entId = pr.readUint32()
      entPosX = pr.readFloat32()
      entPosY = pr.readFloat32()
      entBear = pr.readFloat32()
      #console.log entIdx, entPosX, entPosY, entBear

    #console.log islandId, entCount

  handleSpawn: (pr) ->
    name = pr.readSmallString()
    posX = pr.readFloat32()
    posY = pr.readFloat32()
    bear = pr.readFloat32()

    numAttribs = pr.readUint8()

    for _ in [0...numAttribs]
      attrName = pr.readSmallString()
      attrType = pr.readChar()

      switch attrType
        when 's' then attrVal = pr.readSmallString()
        when 'S' then attrVal = pr.readString()
        when 'f' then attrVal = pr.readFloat32()

      if not attrVal?
        1/0 # i dunno, error or something?

      console.log('Attr', attrName, attrType, attrVal)
