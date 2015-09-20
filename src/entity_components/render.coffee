globals = require '../globals'
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
    @ent.highlighter?.clearHighlight()
    @ent.highlighter = @
    @ent.addChild(@loaded_sprite)
    @ent.depth = 1.5
    @ent.setStage(globals.stage)

  hide: ->
    @ent.highlighter?.clearHighlight()
    @ent.highlighter = null
    @ent.removeChild(@loaded_sprite)

  highlight: ->
    @loaded_sprite.tint = 0xAACCFF
  clearHighlight: ->
    @loaded_sprite.tint = 0xFFFFFF


spineLoader = new pixi.loaders.Loader()

class Spine extends base.ComponentBase
  @character: 'NONE'
  @scale: 1
  @atlas: 'NONE'

  enable: ->
    if @sprite?
      @show()
    else
      if spineLoader.resources[@ent.entityDef.keyHash]?
        if spineLoader.resources[@ent.entityDef.keyHash].spineData?
          @sprite = new spine.Spine(spineLoader.resources[@ent.entityDef.keyHash].spineData)
          @show()
        else
          spineLoader.resources[@ent.entityDef.keyHash].on(
            'complete', =>
              setTimeout =>
                @sprite = new spine.Spine(spineLoader.resources[@ent.entityDef.keyHash].spineData)
                @show()
              , 10
          )
      else
        spineLoader.add(
          @ent.entityDef.keyHash,
          config.ASSET_BASE + @character
        ).load((loader, resources) =>
          @sprite = new spine.Spine(resources[@ent.entityDef.keyHash].spineData)
          @show()
        )
  disable: ->
    @hide()

  show: ->
    @ent.highlighter?.clearHighlight()
    @ent.highlighter = @
    @ent.addChild(@sprite)
    @ent.depth = 2.0
    @ent.setStage(globals.stage)

  hide: ->
    @ent.highlighter?.clearHighlight()
    @ent.highlighter = null
    @ent.removeChild(@sprite)

  highlight: -> # TODO : figure out how to highlight Spine stuff.
  clearHighlight: ->

module.exports =
  Sprite: Sprite
  Spine: Spine