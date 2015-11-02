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

class Camera extends pixi.Container
  constructor: (@world) ->
    super()
    module.exports.current ?= @
    @root = new pixi.Container()
    @target = new pixi.Point()
    @mask = new pixi.Graphics()
    @viewport = new pixi.Rectangle(0,0, 300, 300)
    @frustrum = @viewport.clone()

    @zoom = 1/4.0
    @width = 500
    @height = 500

    @bounded = false

    @_redrawMask()

    @addChild(@root)
    @addChild(@mask)

    @root.addChild(@world)

  Object.defineProperties(@prototype,
    width:
      get: -> @viewport.width
      set: (val) ->
        @viewport.width = val
        @_scaleFrustrum()
        @_constrainFrustrum()
        @_redrawMask()
    height:
      get: -> @viewport.height
      set: (val) ->
        @viewport.height = val
        @_scaleFrustrum()
        @_constrainFrustrum()
        @_redrawMask()
    zoom:
      get: -> @_zoom
      set: (val) ->
        @_zoom = val
        @root.scale.set(val)
        @_constrainFrustrum()
  )

  trackTarget: (dt, target) ->
    diffX = target.x - @target.x
    diffY = target.y - @target.y

    @target.x += diffX * 0.2
    @target.y += diffY * 0.2

  update: (dt) ->
    if @targetEntity
      @trackTarget(dt, @targetEntity.position)

    x = (@target.x * @zoom) - (@width / 2)
    y = (@target.y * @zoom) - (@height / 2)

    @frustrum.x = x / @zoom
    @frustrum.y = y / @zoom

    @_constrainFrustrum()

    @root.position.set(
      -@frustrum.x * @zoom,
      -@frustrum.y * @zoom
    )

    if @bg?
      @bg.tilePosition.set(
        @root.position.x,
        @root.position.y
      )

  _scaleFrustrum: ->
    @frustrum.width = @viewport.width / @zoom
    @frustrum.height = @viewport.height / @zoom

    if @bg?
      @bg.width = @frustrum.width
      @bg.height = @frustrum.height

  _constrainFrustrum: ->
    if not @bounded
      return

    if @frustrum.x < @_bounds.x
      @frustrum.x = @bounds.x

    if @frustrum.y < @_bounds.y
      @frustrum.y = @_bounds.y

    if @frustrum.x + @frustrum.width > @_bounds.x + @_bounds.width
      @frustrum.x = @_bounds.x + @_bounds.width

    if @frustrum.y + @frustrum.height > @_bounds.y + @_bounds.height
      @frustrum.y = @_bounds.y + @_bounds.height

  _redrawMask: ->
    @mask.beginFill()
    @mask.drawRect(0,0, @viewport.width, @viewport.height)
    @mask.endFill()

  onResize: ->
    @viewport.width = window.innerWidth
    @viewport.height = window.innerHeight
    @_scaleFrustrum()
    @_constrainFrustrum()
    @_redrawMask()

  setBackground: (@bgName) ->
    if @bg?
      @removeChild(@bg)

    @bg = new pixi.extras.TilingSprite(
      pixi.Texture.fromImage(
        config.ASSET_BASE + @bgName
      ), @w, @h
    )
    @bg.depth = -100
    # mipmaps and tiles equals yuck.. need to manually mipmap maybe.
    # more likely will just have crud with a transparent background that overlays on top of a solid color.
    # @bg.texture.baseTexture.mipmap = true

    @addChildAt(@bg, 0)

  setTrackingTarget: (@targetEntity) ->

  screenToWorld: (screenPos, y) ->
    if y?
      screenPos = new pixi.Point(screenPos, y)

    ret = new pixi.Point(
      (screenPos.x - @root.position.x) / config.PIXELS_PER_UNIT / @zoom ,
      (screenPos.y - @root.position.y) / config.PIXELS_PER_UNIT / @zoom
    )

    return ret


module.exports =
  Camera: Camera
  current: null
  depthCompare: depthCompare