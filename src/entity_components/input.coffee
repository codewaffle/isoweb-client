pixi = require 'pixi'
base = require './base'
entityController = require('../entity_controller')

class Interactive extends base.ComponentBase
  @hit_area = 'NONE'
  @include_position = false

  enable: ->
    @loaded_hit_area ?= eval ('new pixi.' + @hit_area)
    @ent.hitArea = @loaded_hit_area
    @ent.interactive = true


    @ent.on('mouseover', => @mouseEnter())
    @ent.on('mouseout', => @mouseLeave())
    @ent.on('click', => @mouseClick())
    @ent.on('rightclick', => @mouseAltClick())

  disable: ->
    @ent.hitArea = null
    @ent.interactive = false

  mouseEnter: ->
    @ent.highlighter?.highlight()

  mouseLeave: ->
    @ent.highlighter?.clearHighlight()

  mouseClick: ->
    # perform default command (or return menu if multiple conflicting default commands [it happens])
    console.log('entity position: ' + @ent.position)
    console.log('Requesting contextual command')
    entityController.current.cmdContextual(@ent)

  mouseAltClick: ->
    # get full menu
    entityController.current.cmdMenuReq(@ent)



module.exports =
  Interactive: Interactive

