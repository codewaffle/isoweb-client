entity = require '../entity'
packetTypes = require './packet_types'

module.exports =
  handleEntityUpdate: (pr) ->
    islandId = pr.readUint32()
    entId = pr.readUint32()

    # get or create entity
    ent = entity.get(entId)

    # now read updates til we hit nul
    updateType = pr.readUint16()

    while updateType > 0
      switch updateType
        when packetTypes.POSITION_UPDATE then ent.updatePosition(
          pr.readFloat32(), pr.readFloat32(), pr.readFloat32()
        )
        when packetTypes.STRING_UPDATE then ent.updateAttribute(pr.readSmallString(), pr.readString())

      updateType = pr.readUint16()
