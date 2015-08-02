pixi = require 'pixi'
entity = require './entity'

class Window
  constructor: (ownerId, x, y) ->
    @position = new pixi.Point(x || 0, y || 0)
    @ownerId  = null # entity id
    @visible = false

    # create window DOM
    @domElement = el = document.createElement('div')
    @domElement.className = 'window ui'

    document.body.appendChild(@domElement)
    @domElement.style.left = x + 'px'
    @domElement.style.top = y + 'px'
    return @

  show: ->
    @domElement.style.display = 'visible'
    @visible = true

  hide: ->
    @domElement.style.display = 'none'
    @visible = false

  close: ->
    document.body.removeChild(@domElement)

module.exports =
  Window: Window