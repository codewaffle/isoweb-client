base = require './base'

class Sprite extends base.ComponentBase
  @sprite: 'NONE'
  @scale: 1
  @anchor: {x: 0.5, y: 0.5}

  enable: ->
    @ent.update_anchor_x(@anchor.x)
    @ent.update_anchor_y(@anchor.y)
    @ent.update_scale(@scale)
    @ent.update_sprite(@sprite)

module.exports =
  Sprite: Sprite