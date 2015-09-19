pixi = require 'pixi'
base = require './base'
entityController = require('../entity_controller')

class Interactive extends base.ComponentBase
  @hit_area = 'NONE'

  enable: ->
    @loaded_hit_area ?= eval ('new pixi.' + @hit_area)
    @ent.hitArea = @loaded_hit_area
    @ent.interactive = true

    @onEnter = => @mouseEnter()
    @onLeave = => @mouseLeave()

    @ent.on('mouseover', @onEnter)
    @ent.on('mouseout', @onLeave)

    @ent.on('click', (ev) =>
      # perform default command (or return menu if multiple conflicting default commands [it happens])
      console.log('entity position: ' + @ent.position)
      console.log('Requesting contextual command')
      entityController.current.cmdContextual(@ent)
    )

    @ent.on('rightclick', (ev) =>
      # get full menu
      entityController.current.cmdMenuReq(@ent)
    )

  disable: ->
    @ent.hitArea = null
    @ent.interactive = false

  mouseEnter: ->
    @ent.highlighter?.highlight()

  mouseLeave: ->
    @ent.highlighter?.clearHighlight()

module.exports =
  Interactive: Interactive