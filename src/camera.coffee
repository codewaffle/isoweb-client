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

    return new pixi.Point((screenPos.x - @stage.position.x) / (256/@zoomLevel), (screenPos.y - @stage.position.y)  / (256/@zoomLevel))

  onResize: ->
    h = window.innerHeight
    w = window.innerWidth

    #@container.position.y = h/2
    #@container.position.x = w/2
    @renderer.resize(w, h)

  setTrackingTarget: (@trackingObject) ->

  update: (dt) ->
    if @trackingObject?
      @stage.position.x = -@trackingObject.position.x/@zoomLevel + window.innerWidth/2
      @stage.position.y = -@trackingObject.position.y/@zoomLevel + window.innerHeight/2

module.exports =
  Camera: Camera
  current: null