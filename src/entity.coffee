config = require './config'
components = require './entity_components'
asset = require './asset'
clock = require './clock'
pixi = require 'pixi'
entityController = require('./entity_controller')
entityDef = require './entity_def'
spine = require 'pixi-spine'
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
    @updates = []
    @updating = false
    @attrs = {}
    @sprite = null
    @model = null
    @anchor_x = 0.5
    @anchor_y = 0.5
    @sprite_cbs = []
    @hidden = true
    @name = 'Entity'
    @components = {}

    require('./main').stage.addChild(@)
    # console.log "ENTITY", entCount++

  update_scale: (scale) ->
    @meshScale = scale
    @updateModel()

  update_sprite: (val) ->
    asset.getSprite(val, (spr) =>
      @setSprite(spr)
    )

  update_anchor_x: (val) ->
    @anchor_x = val

  update_anchor_y: (val) ->
    @anchor_y = val

  update_hit_area: (txt) ->
    if @sprite?
      @sprite.interactive = true
      @sprite.hitArea = eval('new pixi.' + txt)
    else
      @sprite_cbs.push( (spr) ->
        spr.interactive = true
        spr.hitArea = eval('new pixi.' + txt)
      )

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
    @updates.push([t,x*256,y*256,r, vx*256, vy*256])

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


    if @entityDef.components.Interactive?
      @update_hit_area(@entityDef.components.Interactive.hit_area)

    if @entityDef.components.Spine?
      @entityDef.addAttribCallback('spineCharacter', (spineCharacter) =>
        @sprite = new spine.Spine(spineCharacter)
        setTimeout =>
          @sprite.state.setAnimationByName(0, "idle", true)
        , Math.random() * 1000

        if not @hidden
          @addChild(@sprite)
      )

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

  setSprite: (@sprite) ->
    @updateModel()
    if @sprite_cbs.length > 0
      for cb in @sprite_cbs
        cb(@sprite)

  takeControl: (@conn) ->
    ec = new entityController.EntityController(@)
    ec.setConnection(@conn)
    ec.takeControl()

  updateModel: ->
    if not (@sprite? and @meshScale?)
      return

    @sprite.scale.x = @meshScale
    @sprite.scale.y = @meshScale
    @sprite.anchor.x = @anchor_x
    @sprite.anchor.y = @anchor_y

    @sprite.on('mouseover', =>
      @sprite.tint = 0xAACCFF
    )

    @sprite.on('mouseout', =>
      @sprite.tint = 0xFFFFFF
    )

    @sprite.on('click', (ev) =>
    # perform default command (or return menu if multiple conflicting default commands [it happens])
      console.log('entity position: ' + @position)
      console.log('Requesting contextual command')
      entityController.current.cmdContextual(@)
    )

    @sprite.on('rightclick', (ev) =>
      # get full menu
      entityController.current.cmdMenuReq(@)
    )

  setEnabled: () ->
    if not @isEnabled
      for key, val of @components
        val.enable()
      @isEnabled = true

    if @hidden
      if @sprite?
        @addChild(@sprite)
      @hidden = false
      @update(0, true)

  setDisabled: () ->
    if @isEnabled
      for key, val of @components
        val.disable()
      @isEnabled = false

    if not @hidden
      if @sprite?
        @removeChild(@sprite)
      @hidden = true

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
      if not ent.update(dt)
        ent.updating = false
        delete updateList[key]
