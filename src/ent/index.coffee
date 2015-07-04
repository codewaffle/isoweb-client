mesh = require './mesh'

module.exports =
  Entity: require './entity'
  mesh: mesh

  map:
    'SimpleSprite': mesh.SimpleSprite
    'SimpleMesh': mesh.SimpleMesh


