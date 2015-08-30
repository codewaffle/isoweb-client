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
em = require './effects_manager'
effects =
  grassSpray: require('./effects/grass_spray').GrassSprayEffect
  smokePuff: require('./effects/smoke_puff').SmokePuffEffect


offline = not location.search != '?offline'

inputManager = new input.InputManager()
menuManager = new menu.MenuManager()
windowManager = new wm.WindowManager()
chatManager = new chat.ChatManager()

renderer = new pixi.autoDetectRenderer(1024, 1024)
renderer.backgroundColor = 0xAAFFCC

stage = new pixi.Container()

cam = new camera.Camera(renderer, stage)
ftm = new ft.FloatingTextManager(stage, cam)
effectsManager = new em.EffectsManager(stage, cam)

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
  else
    # create a sample effect
    cursorWorldPoint = cam.screenToWorld(ev.clientX, ev.clientY)
    effectsManager.playEffect(new effects.grassSpray, cursorWorldPoint.x * 256 - 200, cursorWorldPoint.y * 256, 1000)
    effectsManager.playEffect(new effects.smokePuff, cursorWorldPoint.x * 256 + 200, cursorWorldPoint.y * 256, 1000)

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


bg = new pixi.extras.TilingSprite(
  pixi.Texture.fromImage(config.asset_base + 'tiles/tile_grass.png'), renderer.width, renderer.height)

cam.container.addChildAt(bg, 0)

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

if not offline
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
  bg.width = w / stage.scale.x
  bg.height = h / stage.scale.y
  bg.position.x = -cam.container.position.x/stage.scale.x
  bg.position.y = -cam.container.position.y/stage.scale.y
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


if not offline
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


lastUpdate = null
update = (t) ->
  if not lastUpdate? # initialize on first tick
    lastUpdate = t

  dt = t - lastUpdate
  lastUpdate = t
  entity.update(dt)
  cam.update(dt)
  bg.tilePosition.x = stage.position.x
  bg.tilePosition.y = stage.position.y
  cam.render()
  effectsManager.update(dt)
  debug.update()
  ftm.update(dt)

  # update clicky marker
  if isDragMoving
    cursorWorldPoint = cam.screenToWorld(cursorPoint.x, cursorPoint.y)
    clicker.position.set(cursorWorldPoint.x * 256, cursorWorldPoint.y * 256)

  requestAnimationFrame(update)
requestAnimationFrame(update)