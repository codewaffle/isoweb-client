pixi = require 'pixi'
entity = require './entity'

class FloatingText
  constructor: (@stage, @scale, @text, @entity, offsetX, offsetY, duration) ->
    @offset = new pixi.Point(@offsetX || 0, @offsetY || 0)
    @duration = @ttl = duration || 2000 # milliseconds

    @obj = new pixi.Text(@text,
      font: '16px Courier New'
      fill: 'white'
      dropShadow: true
      dropShadowColor: 'black'
      wordWrap: true
      wordWrapWidth: 200
    )
    @obj.scale = @scale
    @stage.addChild(@obj)

    # adjust offset to center object
    rect = @obj.getBounds()
    @offset.x += -rect.width/2 * @scale.x
    @offset.y += -rect.height * @scale.y

    if @entity?
      # adjust offset to position above entity
      rect = @entity.getBounds()
      @offset.y += -rect.height/2 * @scale.y
    @update(0)

  update: (dt) ->
    @ttl -= dt
    if @ttl <= 0
      @stage.removeChild(@obj)
      return false
    else
      if @entity?
        # update position
        @obj.position.x = @entity.position.x + @offset.x
        @obj.position.y = @entity.position.y + @offset.y
    return true

module.exports =
  FloatingText: FloatingText