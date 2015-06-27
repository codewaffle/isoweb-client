module.exports =
  handleIslandUpdate: (pr) ->
    islandId = pr.readUint32()
    entCount = pr.readUint16()

    for entIdx in [0...entCount]
      entId = pr.readUint32()
      entPosX = pr.readFloat32()
      entPosY = pr.readFloat32()
      entBear = pr.readFloat32()
      console.log entIdx, entPosX, entPosY, entBear

    console.log islandId, entCount

  handleSpawn: (pr) ->
    name = pr.readString()
    console.log name

  handleInfo: (pr) ->
    # server has sent us info
    name = pr.readString()
