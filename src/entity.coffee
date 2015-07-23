config = require './config'
main = require './main'
asset = require './asset'
clock = require './clock'
pixi = require 'pixi'

entCount = 0

updateList = {}

class Entity extends pixi.Container
  constructor: (@id) ->
    super()
    @updates = []
    @updating = false
    @attrs = {}
    @sprite = null
    @model = null
    @anchor_x = 0.5
    @anchor_y = 0.5

    # ugh memory management.. could maybe make these global to save memory but might reduce performance
    @tmpVec0 = new pixi.Point(0,0)
    @tmpVec1 = new pixi.Point(0,0)
    @tmpVec2 = new pixi.Point(0,0)

    main.stage.addChild(@)
    # console.log "ENTITY", entCount++

  update_scale: (scale) ->
    @meshScale = scale
    @updateModel()

  update_sprite: (val) ->
    asset.getSprite(val, (spr) =>
      @setSprite(spr)
    )

  update_z: (val) ->
    # @position.z = val

  update_anchor_x: (val) ->
    @anchor_x = val

  update_anchor_y: (val) ->
    @anchor_y = val

  updatePosition: (pr) ->
    @pushUpdate(
      pr.timestamp,
      pr.readFloat32(),
      pr.readFloat32(),
      pr.readFloat32()
    )

  pushUpdate: (t, x, y, r) ->
    @updates.push([t,x*100,y*100,r])

    if not @updating
      @updating = true
      updateList[@id] = @

  update: () ->
    srv = clock.server_adjusted()

    # discard old updates, keeping the last
    while @updates.length > 0 and @updates[0][0] < srv
      u = @updates.shift()

    if u?
      if @updates.length > 0
        t0 = u[0]
        t1 = @updates[0][0]
        span = t1 - t0

        t = (srv - t0) / span
        # console.log t

        @position.set(u[1] + (@updates[0][1] - u[1]) * t, u[2] + (@updates[0][2] - u[2]) * t)
        @rotation = u[3] + (@updates[0][3] - u[3]) * t
        @updates.unshift(u)
      else
        @position.set(u[1], u[2])
        @rotation = u[3]
        return false

    return true

  updateAttribute: (attrName, attrVal) ->
    @attrs[attrName] = attrVal

    if @['update_' + attrName]?
      @['update_' + attrName](attrVal)

  setGeom: (@geom) ->
    @updateModel()

  setSprite: (@sprite) ->
    @updateModel()

  updateModel: ->
    if not (@sprite? and @meshScale?)
      return

    #@sprite = new pixi.Sprite(@model_map)
    @sprite.scale.x = @meshScale
    @sprite.scale.y = @meshScale
    @sprite.anchor.x = @anchor_x
    @sprite.anchor.y = @anchor_y
    @addChild(@sprite)

    # @add(@mesh)

registry = {}

module.exports =
  get: (id) ->
    registry[id] ?= new Entity(id)
    return registry[id]
  registry: registry
  update: () ->
    for key, ent of updateList
      if not ent.update()
        ent.updating = false
        delete updateList[key]
