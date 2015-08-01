pixi = require 'pixi'

class InputManager
  constructor: () ->
    @mousePos = new pixi.Point()

    document.addEventListener(
      'mousemove',
      (evt) => @onMouseMove(evt)
    )
    document.addEventListener(
      'click',
      (evt) => @onMouseDown(evt)
    )

  onMouseMove: (evt) ->
    @mousePos.set(evt.clientX, evt.clientY)

  onMouseDown: (evt) ->
    require('./main').menuManager.hideContextMenu()

module.exports =
  InputManager: InputManager
