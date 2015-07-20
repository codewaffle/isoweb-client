module.exports =
  handleEntityUpdate: (pr) ->
    islandId = pr.readUint32()
    entId = pr.readUint32()

    # get or create entity

    # now read updates til we hit nul
    updateType = pr.readUint16()


    console.log 'entityUpdate!', islandId, entId
