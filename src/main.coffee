pixi = require 'pixi'
spine = require 'pixi-spine'
pixiExt = require './pixi_extensions'
input = require './input'
entity = require './entity'
config = require './config'
menu = require './menu_manager'
item = require './item'
entityController = require './entity_controller.coffee'
camera = require './camera'
wm = require './window_manager'
chat = require './chat_manager'
ft = require './floating_text_manager'



inputManager = new input.InputManager()
menuManager = new menu.MenuManager()
windowManager = new wm.WindowManager()
chatManager = new chat.ChatManager()

renderer = new pixi.autoDetectRenderer(1024, 1024)
renderer.backgroundColor = 0xAAFFCC

stage = new pixi.Container()

cam = new camera.Camera(renderer, stage)
cam.setBackground('tiles/tile_water.png')

ftm = new ft.FloatingTextManager(stage, cam)

document.body.appendChild(renderer.view)

clicker = {}
pixi.loader.add('clicker', config.asset_base + 'spine/clicker/clicker.json')
pixi.loader.add(config.asset_base + 'spine/clicker/clicker.atlas')
pixi.loader.once('complete', ->
  # assets loaded
  clicker = new spine.Spine.fromAtlas('clicker')
  clicker.scale.set(0.2, 0.2)
  clicker.alpha = 0
  stage.addChild(clicker)
)
pixi.loader.load()


# TODO: all this event handling really needs to get organized somewhere else...

$(document).on('contextmenu', (ev) ->
  ev.preventDefault()
  return false
)

lastClickTarget = null
$(document).on('mousedown', (ev) ->
  lastClickTarget = ev.target

  # TODO : clicking on entities still fires this. fix it.
  ev.preventDefault()
  ev.stopPropagation()

  # check if window at point
  w = windowManager.getAtCoordinates(ev.clientX, ev.clientY)
  if w?
    if (ev.buttons & 1) == 1 # left-click
      windowManager.setFocus(w)
    else if (ev.buttons & 2) == 2 # right-click
      windowManager.closeWindow(w)

  return false
)

$(document).on('mouseup', (ev) ->
  if (ev.buttons & 1) == 0
    if windowManager.draggingWindow?
      windowManager.endDrag()
    else if windowManager.draggingItemData?
      windowManager.dropItem(ev.clientX, ev.clientY)
    return false
)

$(document).on('mousemove', (ev) ->
  if windowManager.draggingWindow?
    windowManager.dragUpdate(ev.clientX, ev.clientY)
  else if windowManager.draggingItemData?
    windowManager.dragItemUpdate(ev.clientX, ev.clientY)

    # add window hover effects when dragging an item around
    w = windowManager.getAtCoordinates(ev.clientX, ev.clientY)
    if w? and w != windowManager.draggingItemData.window # origin
      windowManager.beginItemHover(w)
    else if windowManager.itemHoverWindow?
      windowManager.endItemHover()

  # click and drag on a draggable element
  else if (ev.buttons & 1) == 1 and lastClickTarget == ev.target
    # check if we're in a window
    w = windowManager.getAtCoordinates(ev.clientX, ev.clientY)
    if w?
      # check if we're dragging an item
      el = ev.target
      while el?
        if el.classList.contains('container-item')
          if !el.classList.contains('invalid')
            w.beginDragItem(el, ev.clientX, ev.clientY)
          return false
        el = el.parentElement

      # make sure we're clicking on a draggable window element
      if ev.target.classList.contains('draggable')
        windowManager.beginDrag(w, ev.clientX, ev.clientY)

  return false
)

glslify = require 'glslify'

class LUTFilter extends pixi.AbstractFilter
  constructor: ->
    tmp = glslify('./shader/lut.glsl')
    fragmentSrc = tmp
    console.log(tmp)
    super(null, fragmentSrc, {
      nightLut: {type: 'sampler2D', value: pixi.Texture.fromImage(config.asset_base + 'night_lut.png')}
      morningLut: {type: 'sampler2D', value: pixi.Texture.fromImage(config.asset_base + 'morning_lut.png')}
      fireLut: {type: 'sampler2D', value: pixi.Texture.fromImage(config.asset_base + 'fire_lut.png')}
    })

bla = new LUTFilter()
cam.container.filters = [bla]

$(document).on('keydown', (ev) ->
  if ev.keyCode == 27 # ESC
    if chatManager.isOpen
      chatManager.closeChat()
    else if windowManager.focusWindow?
      windowManager.closeWindow(windowManager.focusWindow)

  if ev.keyCode == 84 and ev.target.tagName != 'INPUT' # 'T'
    chatManager.openChat()
    ev.preventDefault()
    return false

  if ev.keyCode == 70
    if cam.container.filters
      cam.container.filters = null
    else
      cam.container.filters = [bla]

  if ev.keyCode == 8 and ev.target == document.body # backspace
    # prevent backspace from navigating
    return false
)


bgHitArea = new pixi.Container()
bgHitArea.hitArea = new pixi.Rectangle(0, 0, renderer.width, renderer.height)
bgHitArea.interactive = true
cam.container.addChildAt(bgHitArea, 0)

cursorPoint = new pixi.Point()
cursorWorldPoint = null
dragMoveTimer = null
clickerTimer = null
isDragMoving = false
beginDragMoving = ->
  #console.log 'beginDragMoving'
  if isDragMoving
    return

  isDragMoving = true
  cursorWorldPoint = cam.screenToWorld(cursorPoint.x, cursorPoint.y)
  entityController.current.cmdMove(cursorWorldPoint.x, cursorWorldPoint.y)

  if clickerTimer?
    window.clearTimeout(clickerTimer)

  clicker.alpha = 1
  clicker.position.set(cursorWorldPoint.x * 256, cursorWorldPoint.y * 256)
  clicker.state.setAnimationByName(0, "animation", true)

  dragMoveTimer = window.setInterval(->
    cursorWorldPoint = cam.screenToWorld(cursorPoint.x, cursorPoint.y)
    entityController.current.cmdMove(cursorWorldPoint.x, cursorWorldPoint.y)
  , 50)

endDragMoving = ->
  #console.log 'endDragMoving'
  isDragMoving = false

  window.clearInterval(dragMoveTimer)
  if clickerTimer?
    window.clearTimeout(clickerTimer)
  # hide clicker in 500ms
  clickerTimer = window.setTimeout(->
    clicker.alpha = 0
    clickerTimer = null
  , 560)


bgHitArea.on('mousedown', (ev) ->
  cursorPoint.set(ev.data.global.x, ev.data.global.y)
  beginDragMoving()
)
bgHitArea.on('mouseup', (ev) ->
  cursorPoint.set(ev.data.global.x, ev.data.global.y)
  endDragMoving()
)
bgHitArea.on('mousemove', (ev) ->
  cursorPoint.set(ev.data.global.x, ev.data.global.y)
  if (ev.data.originalEvent.buttons & 1) == 1 & !isDragMoving # left-mouse down
    beginDragMoving()
  else if (ev.data.originalEvent.buttons & 1) == 0 & isDragMoving # left-mouse up
    endDragMoving()
)

resize = ->
  h = window.innerHeight
  w = window.innerWidth
  bgHitArea.hitArea.width = renderer.width
  bgHitArea.hitArea.height = renderer.height

# multiple resize handlers for now.. mostly for the hacked-in bg. bg will not always render this way.
$(window).on('resize', cam.onResize)
$(window).on('resize', resize)

cam.onResize()
resize()

module.exports =
  stage: stage
  inputManager: inputManager
  menuManager: menuManager
  windowManager: windowManager
  debugWindow: debug
  chatManager: chatManager
  floatingTextManager: ftm


if location.search != '?offline'
  network = require './network'
  #conn = new network.Connection('ws://codewaffle.com:10000/player')
  conn = new network.Connection('ws://96.40.72.113:10000/player')
else
  # offline stuff goes here...

  # test container 1
  w = windowManager.createContainerWindow('foo', 0, 10, 10)
  w.show()
  w.updateContainer(item.TEST_ITEMS())

  w = windowManager.createContainerWindow('bar', 1, 400, 10)
  w.show()
  w.updateContainer(item.TEST_ITEMS())


debug = windowManager.createDebugWindow()
debug.add('player pos', -> return if entityController.current? then entityController.current.ent.position else '-')
debug.show()


land = new pixi.extras.TilingSprite(
  pixi.Texture.fromImage(
    config.asset_base + 'tiles/tile_grass.png'
  ), 500000, 500000
)
land.texture.baseTexture.mipmap = true


land.position.x = land.position.y = 500000/-2

mask = new pixi.Graphics()
mask.clear()
mask.beginFill(0xFFFFFF)
mask.moveTo(22.41,352.58)
mask.lineTo(45.90,359.70)
mask.lineTo(68.78,356.87)
mask.lineTo(90.56,349.03)
mask.lineTo(111.06,338.15)
mask.lineTo(129.03,322.31)
mask.lineTo(141.80,297.89)
mask.lineTo(149.70,269.06)
mask.lineTo(157.14,244.52)
mask.lineTo(168.14,228.36)
mask.lineTo(185.67,221.27)
mask.lineTo(209.95,220.19)
mask.lineTo(235.69,217.70)
mask.lineTo(257.40,209.11)
mask.lineTo(274.12,195.20)
mask.lineTo(288.69,179.12)
mask.lineTo(307.22,164.61)
mask.lineTo(329.83,150.63)
mask.lineTo(349.90,133.68)
mask.lineTo(358.74,111.55)
mask.lineTo(352.09,85.42)
mask.lineTo(335.25,59.11)
mask.lineTo(319.73,35.66)
mask.lineTo(319.45,15.22)
mask.lineTo(336.09,-5.33)
mask.lineTo(354.60,-28.19)
mask.lineTo(357.52,-51.40)
mask.lineTo(340.18,-71.18)
mask.lineTo(310.23,-85.77)
mask.lineTo(279.64,-96.78)
mask.lineTo(259.22,-108.58)
mask.lineTo(251.02,-124.41)
mask.lineTo(250.39,-144.56)
mask.lineTo(252.66,-168.10)
mask.lineTo(255.16,-194.19)
mask.lineTo(257.73,-223.33)
mask.lineTo(258.30,-254.23)
mask.lineTo(250.40,-279.88)
mask.lineTo(230.74,-293.41)
mask.lineTo(200.93,-291.86)
mask.lineTo(166.60,-278.27)
mask.lineTo(134.88,-261.62)
mask.lineTo(110.11,-251.60)
mask.lineTo(91.66,-251.85)
mask.lineTo(77.17,-262.83)
mask.lineTo(63.16,-279.62)
mask.lineTo(46.80,-292.49)
mask.lineTo(28.19,-295.26)
mask.lineTo(9.24,-290.97)
mask.lineTo(-9.08,-286.08)
mask.lineTo(-27.19,-284.72)
mask.lineTo(-46.04,-287.72)
mask.lineTo(-66.86,-296.01)
mask.lineTo(-90.94,-309.71)
mask.lineTo(-116.83,-320.98)
mask.lineTo(-139.77,-319.37)
mask.lineTo(-155.00,-300.66)
mask.lineTo(-161.60,-269.92)
mask.lineTo(-163.46,-237.43)
mask.lineTo(-167.68,-213.22)
mask.lineTo(-179.20,-200.30)
mask.lineTo(-194.02,-190.96)
mask.lineTo(-205.60,-178.15)
mask.lineTo(-212.25,-161.53)
mask.lineTo(-219.39,-145.96)
mask.lineTo(-235.43,-135.92)
mask.lineTo(-260.26,-128.99)
mask.lineTo(-288.35,-120.78)
mask.lineTo(-314.23,-108.76)
mask.lineTo(-334.22,-92.40)
mask.lineTo(-346.09,-72.42)
mask.lineTo(-349.58,-50.26)
mask.lineTo(-345.29,-27.45)
mask.lineTo(-335.34,-5.32)
mask.lineTo(-323.55,15.41)
mask.lineTo(-312.56,34.86)
mask.lineTo(-303.04,53.43)
mask.lineTo(-293.90,71.30)
mask.lineTo(-284.48,88.46)
mask.lineTo(-276.61,105.68)
mask.lineTo(-271.13,123.82)
mask.lineTo(-266.25,142.65)
mask.lineTo(-255.88,158.77)
mask.lineTo(-238.71,169.98)
mask.lineTo(-220.91,179.47)
mask.lineTo(-209.62,193.61)
mask.lineTo(-206.83,216.92)
mask.lineTo(-207.83,247.69)
mask.lineTo(-204.81,278.17)
mask.lineTo(-192.92,300.20)
mask.lineTo(-171.58,308.38)
mask.lineTo(-144.08,302.69)
mask.lineTo(-117.25,292.88)
mask.lineTo(-95.53,290.86)
mask.lineTo(-77.67,299.36)
mask.lineTo(-60.51,313.98)
mask.lineTo(-42.07,329.63)
mask.lineTo(-21.43,337.24)
mask.lineTo(-0.00,330.16)
mask.scale.x = mask.scale.y = 256
stage.addChild(land)
stage.addChild(mask)
land.mask = mask

#stage.addChild(mask)


lastUpdate = null
update = (t) ->
  if not lastUpdate? # initialize on first tick
    lastUpdate = t

  dt = t - lastUpdate
  lastUpdate = t
  entity.update(dt)
  # cam.setZoom(t/1000)
  cam.update(dt)
  cam.render()
  debug.update()
  ftm.update(dt)

  # update clicky marker
  if isDragMoving
    cursorWorldPoint = cam.screenToWorld(cursorPoint.x, cursorPoint.y)
    clicker.position.set(cursorWorldPoint.x * 256, cursorWorldPoint.y * 256)

  requestAnimationFrame(update)
requestAnimationFrame(update)