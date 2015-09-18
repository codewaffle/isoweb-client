base = require './base'

class TerrainPolygon extends base.ComponentBase
#if @entityDef.components.TerrainPolygon?
#sprite = new pixi.extras.TilingSprite(
#  config.asset_base + @entityDef.components.TerrainPolygon.texture,
#)

module.exports =
  TerrainPolygon: TerrainPolygon