pixi = require 'pixi'

class Camera
  constructor: (@renderer, @stage) ->
    module.exports.current ?= @
    @container = new pixi.Container()
    @container.addChild(@stage)
    @position = new pixi.Point()
    @setZoom(4)

  setZoom: (@zoomLevel) ->
    @stage.scale.x = 1/@zoomLevel
    @stage.scale.y = 1/@zoomLevel

  render: ->
    @renderer.render(@container)

  screenToWorld: (screenPos, y) ->
    if y?
      screenPos = new pixi.Point(screenPos, y)

    return new pixi.Point((screenPos.x - @container.position.x) / (256/@zoomLevel), (screenPos.y - @container.position.y)  / (256/@zoomLevel))

  onResize: ->
    h = window.innerHeight
    w = window.innerWidth

    @container.position.y = h/2
    @container.position.x = w/2
    @renderer.resize(w, h)

  setTrackingTarget: (@trackingObject) ->

  update: (dt) ->


module.exports =
  Camera: Camera
  current: null