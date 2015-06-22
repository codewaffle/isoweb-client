mathx = require '../mathx'
config = require '../config'
three = require 'three'
Chunk = require './chunk'

module.exports = class Island extends three.Object3D
  constructor: (@seed) ->
    super()
    @rng = new mathx.RNG(@seed)
    @width = @rng.randInt(2, 6)
    @height = @rng.randInt(2, 6)

    @chunks = []

    for y in [0..@height]
      for x in [0..@width]
        chunk = new Chunk()
        chunk.position.x = x * config.ChunkSize
        chunk.position.y = y * config.ChunkSize
        @chunks.push(chunk)
        @add(chunk)

