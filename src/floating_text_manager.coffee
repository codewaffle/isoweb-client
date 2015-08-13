pixi = require 'pixi'
ft = require './floating_text'

class FloatingTextManager
  constructor: (@stage, @camera, @defaultOptions) ->
    # TODO : implement default options for floating text
    @instances = []

    # negate camera zoomlevel
    # TODO : this needs to be updated if zoomLevel is changed
    @scale = new pixi.Point(@camera.zoomLevel, @camera.zoomLevel)

  floatText: (text, entity, offsetX, offsetY, duration) ->
      # default duration to 1 second per 10 characters, clamp 3 - 10 seconds
    duration = duration || Math.min(Math.max(3000, text.length/10 * 1000), 10000)
    instance = new ft.FloatingText(@stage, @scale, text, entity, offsetX, offsetY, duration)
    @instances.push(instance)

  update: (dt) ->
    for i in [@instances.length-1..0] by -1
      instance = @instances[i]
      if !instance.update(dt)
        @instances.splice(i, 1)

module.exports =
  FloatingTextManager: FloatingTextManager