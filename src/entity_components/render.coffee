pixi = require 'pixi'
spine = require 'pixi-spine'

asset = require '../asset'
config = require '../config'

base = require './base'

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
    @loaded_sprite.anchor.x = @anchor.x
    @loaded_sprite.anchor.y = @anchor.y
    @loaded_sprite.scale.x = @scale
    @loaded_sprite.scale.y = @scale
    @show()

  show: ->
    @ent.addChild(@loaded_sprite)

  hide: ->
    @ent.removeChild(@loaded_sprite)

spineLoader = new pixi.loaders.Loader()

class Spine extends base.ComponentBase
  @character: 'NONE'
  @scale: 1
  @atlas: 'NONE'

  # TODO : lotta long variables in here.. make them shorter. MUAHAHAHA
  enable: ->
    if not @sprite?
      if spineLoader.resources[@ent.entityDef.keyHash]?
        if spineLoader.resources[@ent.entityDef.keyHash].spineData?
          @sprite = new spine.Spine(spineLoader.resources[@ent.entityDef.keyHash].spineData)
          @ent.addChild(@sprite)
        else
          spineLoader.resources[@ent.entityDef.keyHash].on(
            'complete', =>
              setTimeout =>
                @sprite = new spine.Spine(spineLoader.resources[@ent.entityDef.keyHash].spineData)
                @ent.addChild(@sprite)
              , 10
          )
      else
        spineLoader.add(
          @ent.entityDef.keyHash,
          config.asset_base + @character
        ).load((loader, resources) =>
          @sprite = new spine.Spine(resources[@ent.entityDef.keyHash].spineData)
          @ent.addChild(@sprite)
        )
  disable: ->
    @ent.removeChild(@sprite)

module.exports =
  Sprite: Sprite
  Spine: Spine