entity = require '../entity'
packetTypes = require './packet_types'

module.exports =
  handleEntityUpdate: (conn, pr) ->
    entId = pr.readEntityId()

    # get or create entity
    ent = entity.get(entId)

    # now read updates til we hit nul
    updateType = pr.readUint8()

    while updateType > 0
      switch updateType
        when packetTypes.POSITION_UPDATE then ent.updatePosition(pr)
        when packetTypes.STRING_UPDATE then ent.updateAttribute(pr.readSmallString(), pr.readString())
        when packetTypes.FLOAT_UPDATE then ent.updateAttribute(pr.readSmallString(), pr.readFloat32())
        when packetTypes.INT_UPDATE then ent.updateAttribute(pr.readSmallString(), pr.readUint32())
        when packetTypes.BYTE_UPDATE then ent.updateAttribute(pr.readSmallString(), pr.readUint8())

      updateType = pr.readUint8()
  handleAssignControl: (conn, pr) ->
    entId = pr.readEntityId()

    ent = entity.get(entId)
    ent.takeControl(conn)
  handleEntityMenu: (conn, pr) ->
    entId = pr.readEntityId()

    numItems = pr.readUint8()

    menu = []

    while numItems > 0
      numItems -= 1
      menu.push([
        pr.readSmallString(),
        pr.readSmallString()
      ])

    require('../main').menuManager.showContextMenu(menu, entId)

  handleEntityShow: (conn, pr) ->
    entId = pr.readEntityId()
    ent = entity.get(entId)
    ent.setVisible()

  handleEntityHide: (conn, pr) ->
    entId = pr.readEntityId()
    ent = entity.get(entId)
    ent.setHidden()

  handleEntityDestroy: (conn, pr) ->
    entId = pr.readEntityId()
    ent = entity.get(entId)
    ent.setDestroyed()

  handleContainerUpdate: (conn, pr) ->
    entityContainerId = pr.readEntityId()
    lenContents = pr.readUint16()

    contents = {}

    for x in [0...lenContents]
      idx = pr.readUint16()
      contents[idx] =
        count: pr.readUint32()
        mass: pr.readFloat32()
        volume: pr.readFloat32()
        name: pr.readSmallString()
        sprite: pr.readSmallString()

    # TODO:
    console.log 'TODO : do so mething with contents'
    console.log(contents)

handleContainerShow: (conn, pr) ->
    entityContainerId = pr.readEntityId()
    ent = entity.get(entityContainerId)
  # TODO: showContainer
    showContainerForEntity(ent)

  handleContainerShow: (conn, pr) ->
    entityContainerId = pr.readEntityId()
    ent = entity.get(entityContainerId)
    # TODO: hideContainer
    hideContainerForEntity(ent)


