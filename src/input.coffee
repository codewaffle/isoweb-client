three = require 'three'


class InputManager
  constructor: (@camera) ->
    @mousePos = new three.Vector2()

    @panStart = new three.Vector2()
    @panning = false
    @panEnd = new three.Vector2()

    document.addEventListener(
      'mousemove',
      (evt) => @onMouseMove(evt),
      false
    )
    document.addEventListener(
      'mousedown',
      (evt) => @onMouseDown(evt),
      false
    )
    document.addEventListener(
      'mouseup',
      (evt) => @onMouseUp(evt),
      false
    )

    console.log 'asdf'

  onMouseMove: (evt) ->
    @mousePos.set(
      (evt.clientX / window.innerWidth) * 2 - 1,
      (evt.clientY / window.innerWidth) * -2 + 1
    )

  onMouseDown: (evt) ->
    if not @panning
      @panning = true
      @panStart.copy(@mousePos)

  onMouseUp: (evt) ->
    @panning = false

  update: (dt) ->
    if @panning
      @panEnd.copy(@mousePos)
      @panEnd.sub(@panStart)
      @camera.position.x += @panEnd.x
      @camera.position.y += @panEnd.y


module.exports =
  InputManager: InputManager
