pixi = require 'pixi'

class InputManager
  constructor: () ->
    @mousePos = new pixi.Point()

    $(document).on('mousemove', (ev) => @onMouseMove(ev))
    $(document).on('click', (ev) => @onMouseDown(ev))

  onMouseMove: (ev) ->
    @mousePos.set(ev.clientX, ev.clientY)

  onMouseDown: (ev) ->
    require('./main').menuManager.hideContextMenu()

module.exports =
  InputManager: InputManager
