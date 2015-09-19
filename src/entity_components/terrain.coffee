base = require './base'
pixi = require 'pixi'
config = require '../config'

class StaticPolygon extends base.ComponentBase
  @points: null
  @texture: null

  enable: ->
    if not @sprite?
      @sprite = new pixi.extras.TilingSprite(
        pixi.Texture.fromImage(config.ASSET_BASE + @texture),
        # TODO : use actual bounds of terrain here
        50000, 50000
      )
      @sprite.texture.baseTexture.mipmap = true
      @sprite.position.x = @sprite.position.y = 50000 / -2

    if not @mask?
      @mask = new pixi.Graphics()
      console.log @points
      @mask.clear()
      @mask.beginFill(0xFFFFFF)

      # points list first and last points already match, so pop the front.
      point = @points.shift()

      @mask.moveTo(point[0], point[1])

      for point in @points
        @mask.lineTo(point[0], point[1])

      @mask.scale.x = @mask.scale.y = config.PIXELS_PER_UNIT

    @show()

  disable: ->
    @hide()

  show: ->
    @ent.addChild(@sprite)
    @ent.addChild(@mask)
    @sprite.mask = @mask

  hide: ->
    @ent.removeChild(@sprite)
    @ent.removeChild(@mask)

module.exports =
  StaticPolygon: StaticPolygon