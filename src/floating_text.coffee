pixi = require 'pixi'
entity = require './entity'

FT_MAX_CHAT_LINES = 6

class FloatingText
  constructor: (@stage, @scale, text, @entity, offsetX, offsetY, duration) ->
    @originalOffset = new pixi.Point(offsetX || 0, offsetY || 0)
    @offset = new pixi.Point(offsetX || 0, offsetY || 0)
    @duration = @ttl = duration || 2000 # milliseconds
    @lines = []

    @addText(text)

  createObjects: ->
    if @obj
      @stage.removeChild(@obj)

    @textObj = new pixi.Text(@text,
      font: '16px monospace'
      fill: 'white'
      wordWrap: true
      wordWrapWidth: 200
    )
    @textObj.resolution = window.devicePixelRatio
    @textObj.scale = @scale
    @textObj.anchor.set(0.5, 0.5)

    textBounds = @textObj.getBounds()
    boxWidth = textBounds.width * @scale.x + 100
    boxHeight = textBounds.height * @scale.y + 100

    @obj = new pixi.Graphics()
    @obj.beginFill(0x000000)
    @obj.fillAlpha = 0.4
    @obj.lineAlpha = 0.4
    @obj.lineStyle(2 * @scale.x, 0xffffff)
    @obj.drawRoundedRect(-boxWidth/2, -boxHeight/2, boxWidth, boxHeight, 10 * @scale.x)
    @obj.endFill()

    @obj.addChild(@textObj)
    @textObj.position.set()

    @stage.addChild(@obj)

    @offset.y = @originalOffset.y
    @offset.y += -boxHeight/2

    if @entity?
      # adjust offset to position above entity
      rect = @entity.getBounds()
      @offset.y += -rect.height/2 - 20 * @scale.y

      @obj.position.x = @entity.position.x + @offset.x
      @obj.position.y = @entity.position.y + @offset.y
    else
      @obj.position.x = @offset.x
      @obj.position.y = @offset.y

  addText: (text) ->
    @lines.push(text)
    if @lines.length > FT_MAX_CHAT_LINES
      @lines.splice(0, 1)

    @text = @lines.join('\n\n')
    @ttl = @duration = Math.min(@text.length/10 * 1000 + 3000, 15000) || 2000

    @createObjects()

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