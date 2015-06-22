three = require 'three'
config = require '../config'
Tile = require './tile'

tileMaterial = new three.MeshBasicMaterial({color: 0x00ff00})

module.exports = class Chunk extends three.Object3D
  constructor: () ->
    super()
    @tiles = []

    for y in [0..config.ChunkSize]
      for x in [0..config.ChunkSize]
        t = new Tile()
        t.position.x = x
        t.position.y = y
        @tiles.push(t)

    @rebuild()

  rebuild: ->
    @geom = new three.Geometry() # TODO : what happened to the old @geom?
    for t in @tiles
      @geom.mergeMesh(t)

    @remove(@children)
    @add(new three.Mesh(@geom, tileMaterial))

  getTile: (x, y) ->
    return @tiles[x + (y*config.ChunkSize)]