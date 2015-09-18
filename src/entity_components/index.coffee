base = require './base'
terrain = require './terrain'
render = require './render'


registry =
  ComponentBase: base.ComponentBase
  TerrainPolygon: terrain.TerrainPolygon
  Sprite: render.Sprite


find = (component_name) ->
  return registry[component_name] ? base.ComponentBase

module.exports =
  find: find
  create: (component_name, ent) ->
    cls = find(component_name)
    return new cls(ent)
