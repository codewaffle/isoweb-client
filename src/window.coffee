pixi = require 'pixi'


class Window
  constructor: (windowManager, name, x, y) ->
    @windowManager = windowManager
    @name = name
    @position = new pixi.Point(x || 0, y || 0)

    @visible = false

    # create window DOM
    @domElement = el = document.createElement('div')
    @domElement.className = 'window ui'

    document.body.appendChild(@domElement)
    @domElement.style.display = 'none'
    @domElement.style.left = @position.x + 'px'
    @domElement.style.top = @position.y + 'px'

  show: ->
    @domElement.style.display = 'block'
    @visible = true

  hide: ->
    @domElement.style.display = 'none'
    @visible = false

  close: ->
    document.body.removeChild(@domElement)
    @windowManager.removeWindow(@)

  center: ->
    # centers window horizontally and vertically
    @domElement.style.left = document.body.clientWidth/2 - @domElement.clientWidth/2 + 'px'
    @domElement.style.top = document.body.clientHeight/2 - @domElement.clientHeight/2 + 'px'

module.exports =
  Window: Window