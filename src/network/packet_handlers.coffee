entity = require '../entity'
packetTypes = require './packet_types'
main = require '../main'
item = require '../item'

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

    # close (destroy) container ui if one exists
    w = main.windowManager.getByOwner(entId)
    if w?
      main.windowManager.closeWindow(w)

  handleContainerUpdate: (conn, pr) ->
    entityContainerId = pr.readEntityId()
    ent = entity.get(entityContainerId)

    lenContents = pr.readUint16()

    contents = {}
    items = []

    for x in [0...lenContents]
      idx = pr.readUint16()
      contents[idx] =
        idx: idx
        count: pr.readUint32()
        mass: pr.readFloat32()
        volume: pr.readFloat32()
        name: pr.readSmallString()
        sprite: pr.readSmallString()
      itm = new item.Item(
        contents[idx].idx,
        contents[idx].name,
        contents[idx].count,
        contents[idx].weight,
        contents[idx].volume,
        contents[idx].sprite)
      items.push(itm)

    items.sort((a, b) -> return a.id - b.id) # id == idx

    # create or update existing container ui
    w = main.windowManager.getByOwner(entityContainerId) ||
      main.windowManager.createContainerWindow(ent.name + '\'s Contents', entityContainerId).center()
    w.show().focus()
    w.updateContainer(items)

  handleContainerShow: (conn, pr) ->
    entityContainerId = pr.readEntityId()
    ent = entity.get(entityContainerId)

    # create/show existing container ui
    w = main.windowManager.getByOwner(entityContainerId) ||
      main.windowManager.createContainerWindow(ent.name + '\'s Contents', entityContainerId).center()
    w.show().focus()

  handleContainerHide: (conn, pr) ->
    entityContainerId = pr.readEntityId()
    ent = entity.get(entityContainerId)

    # hide container ui
    w = main.windowManager.getByOwner(entityContainerId)
    if w?
      w.hide()

  handleMessage: (conn, pr) ->
    messageType = pr.readUint8()

    switch messageType
      when 0
        # system
        message = pr.readString()
        SHOW_SYSTEM_MESSAGE(message)
      when 1
        # chat
        sender = pr.readSmallString()
        message = pr.readString()
        SHOW_CHAT_MESSAGE(sender, message)
      when 2
        # positional
        x = pr.readFloat32()
        y = pr.readFloat32()
        duration = pr.readFloat32() # in seconds
        message = pr.readString()

        # TODO : support for animation types? not sure if 1 animation suits all popup
        SHOW_POSITIONAL_TEXT(x, y, duration, message)
      else
        console.error("invalid message type")