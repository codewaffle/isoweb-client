pixi = require 'pixi'
base = require './base'

class Interactive extends base.ComponentBase
  @hit_area = 'NONE'

  enable: ->
    @loaded_hit_area ?= eval ('new pixi.' + @hit_area)
    @ent.hitArea = @loaded_hit_area
    @ent.interactive = true

  disable: ->
    @ent.hitArea = null
    @ent.interactive = false

module.exports =
  Interactive: Interactive