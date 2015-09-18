base = require './base'
terrain = require './terrain'

module.exports =
  ComponentBase: base.ComponentBase
  TerrainPolygon: terrain.TerrainPolygon
  find: (component_name) ->
    return module.exports[component_name] ? base.ComponentBase
  create: (component_name) ->
    cls = module.exports.find(component_name)
    return new cls()
