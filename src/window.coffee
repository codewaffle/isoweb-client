pixi = require 'pixi'

WINDOW_TYPE_CONTAINER = 0

class Window
  constructor: (type, ownerId, x, y) ->
    @type = type
    @position = new pixi.Point(x || 0, y || 0)
    @ownerId  = null # entity id
    @visible = false

    # create DOM
    el = document.createElement('div')
    el.className = 'ui window'

    document.appendChild(el)
    el.style.left = x + 'px'
    el.style.top = y + 'px'


    return @


  show: ->
    @domElement.style.display = 'visible';
    @visible = true

