pixi = require 'pixi'


class Window
  constructor: (windowManager, name, x, y) ->
    @windowManager = windowManager
    @name = name
    @position = new pixi.Point(x || 0, y || 0)

    @visible = false
    @isDragging = false
    @dragOffset = new pixi.Point()

    # create window DOM
    @domElement = el = document.createElement('div')
    @domElement.className = 'window ui draggable'

    document.body.appendChild(@domElement)
    @domElement.style.display = 'none'
    @setPosition(@position.x, @position.y)

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

  beginDrag: (x, y) ->
    @dragOffset.set(x - @position.x, y - @position.y)
    @isDragging = true
    @domElement.classList.add('dragging')

  endDrag: ->
    @isDragging = false
    @domElement.classList.remove('dragging')

  setPosition: (x, y) ->
    @position.set(x, y)
    @domElement.style.left = x + 'px'
    @domElement.style.top = y + 'px'

module.exports =
  Window: Window