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
    if entity?
      # check for existing instance for this entity
      for instance in @instances
        if instance.entity == entity
          instance.addText(text)
          return

    # default duration: 3s + 1s per 10 characters, max 15s
    duration = duration || Math.min(text.length/10 * 1000 + 3000, 15000)
    instance = new ft.FloatingText(@stage, @scale, text, entity, offsetX, offsetY, duration)
    @instances.push(instance)

  update: (dt) ->
    for i in [@instances.length-1..0] by -1
      instance = @instances[i]
      if !instance.update(dt)
        @instances.splice(i, 1)

module.exports =
  FloatingTextManager: FloatingTextManager