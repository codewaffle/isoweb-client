packetTypes = require './network/packet_types'
camera = require './camera'

_setSmallString = (buf, idx, str) ->
  buf.setUint8(idx, str.length)
  for i in [0...str.length]
    buf.setUint8(i+idx+1, str.charCodeAt(i))

  return idx + 1 + str.length

_setString = (buf, idx, str) ->
  buf.setUint16(idx, str.length)
  for i in [0...str.length]
    buf.setUint8(i+idx+1, str.charCodeAt(i))

  return idx + 1 + str.length

class EntityController
  constructor: (@ent) ->
  setConnection: (@conn) ->
    # as a test, send cmdMove immediately
    # TODO : remove this once we have better ways to test
    #@cmdMove(-8.0 + Math.random() * 16.0, -8.0 + Math.random() * 16.0)

  takeControl: () ->
    module.exports.current = @
    camera.current?.setTrackingTarget(@ent)
    # TODO : set this controller as our main controller. follow this entity, use it for HUDs, etc...
    # TODO : input should pipe through here to the server
    # TODO : the server may send a TakeControl request at any time to switch the player to a different entity.

  cmdMove: (x, y) ->
    # request to move to world coords x, y
    pkt = new DataView(new ArrayBuffer(9))
    pkt.setUint8(0, packetTypes.CMD_CONTEXTUAL_POSITION)
    pkt.setFloat32(1, x)
    pkt.setFloat32(5, y)
    @conn.sendBinary(pkt.buffer)

  cmdContextual: (targetEnt) ->
    # request to perform a contextual action
    pkt = new DataView(new ArrayBuffer(5))
    pkt.setUint8(0, packetTypes.CMD_CONTEXTUAL_ENTITY)
    pkt.setUint32(1, targetEnt.id)
    @conn.sendBinary(pkt.buffer)

  # TODO : handle menu response...
  cmdMenuReq: (targetEnt) ->
    # request the menu for targetEnt
    pkt = new DataView(new ArrayBuffer(1+4))
    pkt.setUint8(0, packetTypes.CMD_MENU_REQ_ENTITY)
    pkt.setUint32(1, targetEnt.id)
    @conn.sendBinary(pkt.buffer)

  cmdMenuExec: (targetEnt, action) ->
    # try to execute menu action actionId on entity targetEnt
    pkt = new DataView(new ArrayBuffer(1+4+1+action.length))
    pkt.setUint8(0, packetTypes.CMD_MENU_EXEC_ENTITY)
    pkt.setUint32(1, targetEnt.id)
    _setSmallString(pkt, 5, action)
    @conn.sendBinary(pkt.buffer)

  cmdChat: (message) ->
    pkt = new DataView(new ArrayBuffer(1+2+message.length))
    pkt.setUint8(0, packetTypes.MESSAGE)
    _setString(pkt, 1, message)
    @conn.sendBinary(pkt.buffer)

module.exports =
  EntityController: EntityController
  current: null
