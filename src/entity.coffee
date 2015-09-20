globals = require './globals'
config = require './config'
components = require './entity_components'
asset = require './asset'
clock = require './clock'
pixi = require 'pixi'
entityController = require('./entity_controller')
entityDef = require './entity_def'
entCount = 0

updateList = {}

lerp_bearing = (a, b, t) ->
  diff = b - a
  if diff > Math.PI
    a += 2*Math.PI
  else if diff < -Math.PI
    a -= 2*Math.PI

  return a + (b - a) * t

class Entity extends pixi.Container
  constructor: (@id) ->
    super()
    @isEnabled = null
    @updates = []
    @updating = false
    @attrs = {}
    @model = null
    @anchor_x = 0.5
    @anchor_y = 0.5
    @name = 'Entity'
    @components = {}
    @depth = 0

  setStage: (stage) ->
    if stage != @stage
      if @stage?
        @stage.removeChild(@)
      @stage = stage

      if @stage?
        @stage.addChild(@)

  updatePosition: (pr) ->
    @pushUpdate(
      pr.timestamp,
      pr.readFloat32(),
      pr.readFloat32(),
      pr.readFloat32(),
      pr.readFloat32(),
      pr.readFloat32()
    )

  updateParent: (pr) ->
    entId = pr.readEntityId()
    # TODO : queue it up.. parent changes need to happen inline with position changes.
    console.log 'update parent, set to:', entId

  pushUpdate: (t, x, y, r, vx, vy) ->
    @updates.push([t,x*config.PIXELS_PER_UNIT,y*config.PIXELS_PER_UNIT,r, vx*config.PIXELS_PER_UNIT, vy*config.PIXELS_PER_UNIT])

    if not @updating
      @updating = true
      updateList[@id] = @

  update: (dt, init) ->
    # fancy pants interpolation and extrapolation and other things in this method
    srv = clock.server_adjusted()

    # discard old updates, keeping the last
    while @updates.length > 0 and @updates[0][0] <= srv
      u = @updates.shift()

    if u?
      if @updates.length > 0
        t0 = u[0]
        t1 = @updates[0][0]
        span = t1 - t0

        t = (srv - t0) / span
        # console.log t

        @position.set(u[1] + (@updates[0][1] - u[1]) * t, u[2] + (@updates[0][2] - u[2]) * t)
        @rotation = lerp_bearing(u[3], @updates[0][3], t)
        @updates.unshift(u)
        return true
      else
        if srv - u[0] > 0.5 # no movement packet for 500ms
          @position.set(u[1], u[2])
          @rotation = u[3]

          return false

        # we have a past position but no future position is waiting.. extrapolate with position
        over = srv - u[0]
        @position.set(u[1] + u[4] * over, u[2] + u[5] * over)
        @rotation = lerp_bearing(@rotation, u[3], 0.15)
        @updates.unshift(u)

        return true

    if @updates.length > 0
      if init? # set position from the future
        u = @updates[0]
        @position.set(u[1], u[2])
        @rotation = u[3]
      return true

    return false

  updateEntityDef: (defHash) ->
    if @entityDef?
      console.error("no support for reassigning entityDefs yet.. but whatever")

    @entityDef = entityDef.get(defHash)
    @updateComponents(@entityDef.components)

  updateAttribute: (attrName, attrVal) ->
    @attrs[attrName] = attrVal

    if @['update_' + attrName]?
      @['update_' + attrName](attrVal)

  updateComponents: (data) ->
    for component_name of data
      if not @components[component_name]?
        @components[component_name] = components.create(component_name, @)

      @components[component_name].updateData(data[component_name])

  setGeom: (@geom) ->
    @updateModel()

  takeControl: (@conn) ->
    ec = new entityController.EntityController(@)
    ec.setConnection(@conn)
    ec.takeControl()

  setEnabled: () ->
    if @isEnabled
      return

    for key, val of @components
      val.enable()

    @isEnabled = true
    @update(0, true)

  setDisabled: () ->
    if not @isEnabled
      return

    for key, val of @components
      val.disable()
    @isEnabled = false

  setDestroyed: () ->
    if @parent?
      @parent.removeChild(@)

      @sprite.destroy()
      @destroy()


registry = {}

module.exports =
  get: (id) ->
    registry[id] ?= new Entity(id)
    return registry[id]
  registry: registry
  update: (dt) ->
    for key, ent of updateList
      if not ent.update(dt)  # update returns falsey if we should stop updating the entity.
        ent.updating = false
        delete updateList[key]
