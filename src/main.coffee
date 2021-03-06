globals = require './globals'
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
  fire: require('./effects/fire').FireEffect


offline = location.search == '?offline'

inputManager = new input.InputManager()
menuManager = new menu.MenuManager()
windowManager = new wm.WindowManager()
chatManager = new chat.ChatManager()

renderer = new pixi.autoDetectRenderer(1024, 1024)
renderer.backgroundColor = 0xAAFFCC

cam = new camera.Camera(renderer)
cam.setBackground('tiles/tile_water.png')

ftm = new ft.FloatingTextManager(cam.stage, cam)
effectsManager = new em.EffectsManager(cam.stage, cam)

document.body.appendChild(renderer.view)

clicker = {}
pixi.loader.add('clicker', config.ASSET_BASE + 'spine/clicker/clicker.json')
pixi.loader.add(config.ASSET_BASE + 'spine/clicker/clicker.atlas')
pixi.loader.once('complete', ->
  # assets loaded
  clicker = new spine.Spine.fromAtlas('clicker')
  clicker.scale.set(0.2, 0.2)
  clicker.alpha = 0
  cam.stage.addChild(clicker)
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
      nightLut: {type: 'sampler2D', value: pixi.Texture.fromImage(config.ASSET_BASE + 'night_lut.png')}
      morningLut: {type: 'sampler2D', value: pixi.Texture.fromImage(config.ASSET_BASE + 'morning_lut.png')}
      fireLut: {type: 'sampler2D', value: pixi.Texture.fromImage(config.ASSET_BASE + 'fire_lut.png')}
    })

bla = new LUTFilter()
cam.setFilter(bla)

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
    if cam.setFilter(null)
    else
      cam.setFilter(bla)

  if ev.keyCode == 8 and ev.target == document.body # backspace
    # prevent backspace from navigating
    return false
)

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
  clicker.position.set(cursorWorldPoint.x * config.PIXELS_PER_UNIT, cursorWorldPoint.y * config.PIXELS_PER_UNIT)
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


resize = ->
  h = window.innerHeight
  w = window.innerWidth

# multiple resize handlers for now.. mostly for the hacked-in bg. bg will not always render this way.
$(window).on('resize', cam.onResize)
$(window).on('resize', resize)

cam.onResize()
resize()

module.exports =
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
  # cam.setZoom(t/1000)
  cam.update(dt)
  cam.render()
  effectsManager.update(dt)
  debug.update()
  ftm.update(dt)

  # update clicky marker
  if isDragMoving
    cursorWorldPoint = cam.screenToWorld(cursorPoint.x, cursorPoint.y)
    clicker.position.set(cursorWorldPoint.x * config.PIXELS_PER_UNIT, cursorWorldPoint.y * config.PIXELS_PER_UNIT)

  requestAnimationFrame(update)
requestAnimationFrame(update)