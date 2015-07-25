packetTypes = require './network/packet_types'

class EntityController
  constructor: (@ent) ->
  setConnection: (@conn) ->
    # as a test, send cmdMove immediately
    # TODO : remove this once we have better ways to test
    @cmdMove(-32.0 + Math.random() * 64.0, -32.0 + Math.random() * 64.0)

  takeControl: () ->
    # TODO : set this controller as our main controller. follow this entity, use it for HUDs, etc...
    # TODO : input should pipe through here to the server
    # TODO : the server may send a TakeControl request at any time to switch the player to a different entity.

  cmdMove: (x, y) ->
    # request to move to world coords x, y
    pkt = new DataView(new ArrayBuffer(9))
    pkt.setUint8(0, packetTypes.CMD_MOVE)
    pkt.setFloat32(1, x)
    pkt.setFloat32(5, y)
    @conn.sendBinary(pkt.buffer)

  cmdContextual: (targetEnt) ->
    # request to perform a contextual action
    pkt = new DataView(new arrayBuffer(5))
    pkt.setUint8(0, packetTypes.CMD_CONTEXTUAL)
    pkt.setUint32(1, targetEnt.id)
    @conn.sendBinary(pkt.buffer)

  # TODO : handle menu response...
  cmdMenuReq: (targetEnt) ->
    # request the menu for targetEnt
    pkt = new DataView(new ArrayBuffer(1+4))
    pkt.setUint8(0, packetTypes.CMD_MENU_REQ)
    pkt.setUint32(1, targetEnt.id)
    @conn.sendBinary(pkt.buffer)

  cmdMenuExec: (targetEnt, actionId) ->
    # try to execute menu action actionId on entity targetEnt
    pkt = new DataView(new ArrayBuffer(1+4+2))
    pkt.setUint8(0, packetTypes.CMD_MENU_EXEC)
    pkt.setUint32(1, targetEnt.id)
    pkt.setUint16(5, actionId)
    @conn.sendBinary(pkt.buffer)

module.exports =
  EntityController: EntityController
