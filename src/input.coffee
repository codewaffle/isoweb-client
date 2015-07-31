pixi = require 'pixi'

class InputManager
  constructor: () ->
    @mousePos = new pixi.Point()

    document.addEventListener(
      'mousemove',
      (evt) => @onMouseMove(evt),
      false
    )

  onMouseMove: (evt) ->
    @mousePos.set(
      (evt.clientX / window.innerWidth) * 2 - 1,
      (evt.clientY / window.innerWidth) * -2 + 1
    )

module.exports =
  InputManager: InputManager
