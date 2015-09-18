base = require './base'
asset = require '../asset'

class Sprite extends base.ComponentBase
  @sprite: 'NONE'
  @scale: 1
  @anchor: {x: 0.5, y: 0.5}
  loaded_sprite: null

  constructor: (@ent) ->

  enable: ->
    if not @loaded_sprite?
      asset.getSprite(@sprite, (spr) =>
        @setSprite(spr)
      )
    else
      @show()

  disable: ->
    @hide()

  setSprite: (@loaded_sprite) ->
    # spr is the pixi sprite.. ahh
    @show()

  show: ->
    @ent.addChild(@loaded_sprite)

  hide: ->
    @ent.removeChild(@loaded_sprite)

class Spine extends base.ComponentBase
#  if @entityDef.components.Spine?
#    @entityDef.addAttribCallback('spineCharacter', (spineCharacter) =>
#      @sprite = new spine.Spine(spineCharacter)
#      setTimeout =>
#        @sprite.state.setAnimationByName(0, "idle", true)
#      , Math.random() * 1000
#
#      if not @hidden
#        @addChild(@sprite)
#    )


module.exports =
  Sprite: Sprite
  Spine: Spine