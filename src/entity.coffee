config = require './config'
three = require 'three'
main = require './main'

jsonLoader = new three.JSONLoader()
texLoader = new three.TextureLoader()

class Entity extends three.Object3D
  constructor: (@id) ->
    super()
    @attrs = {}
    @sprite = null
    @model = null
    main.scene.add(@)

  update_sprite: (val) ->
  update_model: (val) ->
    jsonLoader.load(
      config.asset_base + val,
      (geom, materials) =>
        @setGeom(geom)
    )
  update_map: (val) ->
    texLoader.load(
      config.asset_base + val,
      (tex) =>
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
    if @model_map?
      @updateModel()

  setMap: (@model_map) ->
    if @geom?
      @updateModel()

  updateModel: ->
    @material = new three.MeshPhongMaterial({map: @model_map})
    @mesh = new three.Mesh(@geom, @material)
    @mesh.castShadow = true
    @mesh.receiveShadow = true
    @add(@mesh)

registry = {}

module.exports =
  get: (id) ->
    registry[id] ?= new Entity(id)
    return registry[id]
  registry: registry