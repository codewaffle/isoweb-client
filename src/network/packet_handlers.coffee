entity = require '../entity'
packetTypes = require './packet_types'

module.exports =
  handleEntityUpdate: (pr) ->
    entId = pr.readUint32()

    # get or create entity
    ent = entity.get(entId)

    # now read updates til we hit nul
    updateType = pr.readUint8()

    while updateType > 0
      switch updateType
        when packetTypes.POSITION_UPDATE then ent.updatePosition(pr)
        when packetTypes.STRING_UPDATE then ent.updateAttribute(pr.readSmallString(), pr.readString())
        when packetTypes.FLOAT_UPDATE then ent.updateAttribute(pr.readSmallString(), pr.readFloat32())

      updateType = pr.readUint8()
