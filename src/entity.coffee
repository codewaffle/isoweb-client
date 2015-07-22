config = require './config'
three = require 'three'
main = require './main'
asset = require './asset'
clock = require './clock'

jsonLoader = new three.JSONLoader()
texLoader = new three.TextureLoader()
entCount = 0

updateList = {}

class Entity extends three.Object3D
  constructor: (@id) ->
    super()
    @updates = []
    @updating = false
    @attrs = {}
    @sprite = null
    @model = null

    # ugh memory management.. could maybe make these global to save memory but might reduce performance
    @tmpVec0 = new three.Vector3(0,0,0)
    @tmpVec1 = new three.Vector3(0,0,0)
    @tmpVec2 = new three.Vector3(0,0,0)

    main.scene.add(@)
    # console.log "ENTITY", entCount++

  update_scale: (scale) ->
    @meshScale = scale
    @updateModel()

  update_model: (val) ->
    asset.getGeom(val, (geom) =>
      @setGeom(geom)
    )

  update_map: (val) ->
    asset.getTexture(val, (tex) =>
      @setMap(tex)
    )

  update_z: (val) ->
    @position.z = val

  updatePosition: (pr) ->
    @pushUpdate(
      pr.timestamp,
      pr.readFloat32(),
      pr.readFloat32(),
      pr.readFloat32()
    )

  pushUpdate: (t, x, y, r) ->
    @updates.push([t,x,y,r])

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

        @tmpVec0.set(u[1], u[2], u[3])
        @tmpVec1.set(@updates[0][1], @updates[0][2], @updates[0][3])
        @tmpVec0.lerp(@tmpVec1, t)

        @position.set(@tmpVec0.x, @tmpVec0.y, @position.z)
        @rotation.z = @tmpVec0.z
        @updates.unshift(u)
      else
        @position.set(u[1], u[2], @position.z)
        @rotation.z = u[3]
        return false

    return true

  updateAttribute: (attrName, attrVal) ->
    @attrs[attrName] = attrVal

    if @['update_' + attrName]?
      @['update_' + attrName](attrVal)

  setGeom: (@geom) ->
    @updateModel()

  setMap: (@model_map) ->
    @updateModel()

  updateModel: ->
    if not (@geom? and @model_map? and @meshScale?)
      return

    @material = new three.MeshPhongMaterial({map: @model_map, transparent: true})
    @mesh = new three.Mesh(@geom, @material)
    @mesh.scale.set(@meshScale,@meshScale,@meshScale)
    @mesh.castShadow = true
    @mesh.receiveShadow = true
    @add(@mesh)

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
        console.log 'end update'
        delete updateList[key]
