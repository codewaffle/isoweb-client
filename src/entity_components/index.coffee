base = require './base'
terrain = require './terrain'
render = require './render'
input = require './input'

registry =
  ComponentBase: base.ComponentBase
  TerrainPolygon: terrain.TerrainPolygon
  Sprite: render.Sprite
  Spine: render.Spine
  Interactive: input.Interactive

find = (component_name) ->
  return registry[component_name] ? base.EchoBase

module.exports =
  find: find
  create: (component_name, ent) ->
    cls = find(component_name)
    return new cls(ent)
