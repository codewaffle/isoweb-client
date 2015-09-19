pixi = require 'pixi'
config = require './config'

depthCompare = (a, b) ->
  aDepth = a.depth ? 0
  bDepth = b.depth ? 0

  if aDepth > bDepth
    return 1
  if aDepth < bDepth
    return -1

  return 0

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
    @stage.children.sort(depthCompare)
    @renderer.render(@container)

  setBackground: (@bgName) ->
    if @bg?
      @container.removeChild(@bg)

    @bg = new pixi.extras.TilingSprite(
      pixi.Texture.fromImage(
        config.ASSET_BASE + @bgName
      ), @w, @h
    )
    @bg.depth = -100
    # mipmaps and tiles equals yuck.. need to manually mipmap maybe.
    # more likely will just have crud with a transparent background that overlays on top of a solid color.
    # @bg.texture.baseTexture.mipmap = true

    @container.addChildAt(@bg, 0)

  screenToWorld: (screenPos, y) ->
    if y?
      screenPos = new pixi.Point(screenPos, y)

    return new pixi.Point(
      (screenPos.x - @stage.position.x) / (config.PIXELS_PER_UNIT/@zoomLevel),
      (screenPos.y - @stage.position.y)  / (config.PIXELS_PER_UNIT/@zoomLevel)
    )

  onResize: ->
    @h = window.innerHeight
    @w = window.innerWidth

    if @bg?
      @bg.width = @w
      @bg.height = @h
      @bg.tileScale.x = @bg.tileScale.y = 1/@zoomLevel
      @bg.position.x = @container.position.x * @zoomLevel * -1
      @bg.position.y = @container.position.y * @zoomLevel * -1

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