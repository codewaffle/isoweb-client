pixi = require 'pixi'
config = require './config'

class Camera
  constructor: (@renderer, @stage) ->
    module.exports.current ?= @
    @container = new pixi.Container()
    @container.addChild(@stage)
    @position = new pixi.Point()
    @setZoom(4)
    @w = @h = 0

  setZoom: (@zoomLevel) ->
    @stage.scale.x = 1/@zoomLevel
    @stage.scale.y = 1/@zoomLevel
    @onResize()

  render: ->
    @renderer.render(@container)

  setBackground: (@bgName) ->
    if @bg?
      @container.removeChild(@bg)

    @bg = new pixi.extras.TilingSprite(
      pixi.Texture.fromImage(
        config.asset_base + @bgName
      ), @w, @h
    )

    @container.addChildAt(@bg, 0)

  screenToWorld: (screenPos, y) ->
    if y?
      screenPos = new pixi.Point(screenPos, y)

    return new pixi.Point((screenPos.x - @stage.position.x) / (256/@zoomLevel), (screenPos.y - @stage.position.y)  / (256/@zoomLevel))

  onResize: ->
    @h = window.innerHeight
    @w = window.innerWidth

    if @bg?
      @bg.width = @w
      @bg.height = @h
      @bg.tileScale.x = @bg.tileScale.y = 1/@zoomLevel
      @bg.position.x = @container.position.x * @zoomLevel * -1
      @bg.position.y = @container.position.y * @zoomLevel * -1

    #@container.position.y = h/2
    #@container.position.x = w/2
    if @renderer?
      @renderer.resize(@w, @h)

  setTrackingTarget: (@trackingObject) ->

  update: (dt) ->
    if @trackingObject?
      @stage.position.x += ((-@trackingObject.position.x/@zoomLevel + window.innerWidth/2) - @stage.position.x) * 0.5
      @stage.position.y += ((-@trackingObject.position.y/@zoomLevel + window.innerHeight/2) - @stage.position.y) * 0.5

    if @bg?
      @bg.tilePosition.x = @stage.position.x
      @bg.tilePosition.y = @stage.position.y

module.exports =
  Camera: Camera
  current: null