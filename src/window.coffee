pixi = require 'pixi'


class Window
  constructor: (@windowManager, @name, x, y) ->
    @position = new pixi.Point(x || 0, y || 0)

    @visible = false
    @isDragging = false
    @dragOffset = new pixi.Point()
    @canHaveFocus = true
    @canClose = true

    # create window DOM
    @domElement = el = document.createElement('div')
    @domElement.className = 'window ui draggable'

    document.body.appendChild(@domElement)
    @domElement.style.display = 'none'
    @setPosition(@position.x, @position.y)
    return @

  show: ->
    return @windowManager.showWindow(@)

  hide: ->
    return @windowManager.hideWindow(@)

  close: ->
    @windowManager.closeWindow(@)

  center: ->
    # centers window horizontally and vertically
    @setPosition(
      document.body.clientWidth/2 - @domElement.clientWidth/2,
      document.body.clientHeight/2 - @domElement.clientHeight/2)
    return @

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
    return @

  focus: ->
    @windowManager.setFocus(@)
    return @

  blur: ->
    @domElement.classList.remove('focus')
    @domElement.style.zIndex = '0'
    return @

  beginDragItem: (id, x, y) ->
    @windowManager.beginDragItem(@, id, x, y)

  endDragItem: ->
    @windowManager.endDragItem()

  beginItemHover: ->
    @windowManager.beginItemHover(@)

  endItemHover: ->
    @windowManager.endItemHover()

module.exports =
  Window: Window