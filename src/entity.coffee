config = require './config'
three = require 'three'
main = require './main'
asset = require './asset'

jsonLoader = new three.JSONLoader()
texLoader = new three.TextureLoader()

class Entity extends three.Object3D
  constructor: (@id) ->
    super()
    @attrs = {}
    @sprite = null
    @model = null
    main.scene.add(@)

  update_scale: (scale) ->
    @meshScale = parseFloat(scale)
    @updateModel()

  update_model: (val) ->
    asset.getGeom(val, (geom) =>
      @setGeom(geom)
    )

  update_map: (val) ->
    asset.getTexture(val, (tex) =>
      @setMap(tex)
    )

  updatePosition: (x, y) ->
    @position.x = x
    @position.y = y

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