three = require 'three'

geom = new three.Geometry()

geom.vertices.push(new three.Vector3(-0.45, -0.45, 0))
geom.vertices.push(new three.Vector3(0.45, -0.45, 0))
geom.vertices.push(new three.Vector3(-0.45, 0.45, 0))

geom.vertices.push(new three.Vector3(0.45, 0.45, 0))

geom.faces.push(new three.Face3(0,1,2))
geom.faces.push(new three.Face3(1,3,2))

geom.computeFaceNormals()
geom.computeVertexNormals()

module.exports = class Tile extends three.Mesh
  constructor: () ->
    #material = new three.MeshLambertMaterial({color: 0x00ff00, side: three.DoubleSide})
    material = new three.MeshBasicMaterial({color: 0x00ff00, side: three.DoubleSide})
    super(geom, material)
