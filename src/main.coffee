pixi = require 'pixi'
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
ftm = new ft.FloatingTextManager(stage, cam)

document.body.appendChild(renderer.view)


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
    else if windowManager.draggingItem?
      windowManager.dropItem(ev.clientX, ev.clientY)
    return false
)

$(document).on('mousemove', (ev) ->
  if windowManager.draggingWindow?
    windowManager.dragUpdate(ev.clientX, ev.clientY)
  else if windowManager.draggingItem?
    windowManager.dragItemUpdate(ev.clientX, ev.clientY)

    # add window hover effects when dragging an item around
    w = windowManager.getAtCoordinates(ev.clientX, ev.clientY)
    if w? and w.ownerId != windowManager.draggingItem.ownerId # origin
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
          w.beginDragItem(el, ev.clientX, ev.clientY)
          return false
        el = el.parentElement

      # make sure we're clicking on a draggable window element
      if ev.target.classList.contains('draggable')
        windowManager.beginDrag(w, ev.clientX, ev.clientY)

  return false
)

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

bgHitArea.on('click', (ev) ->
  point = cam.screenToWorld(ev.data.global.x, ev.data.global.y)
  entityController.current.cmdMove(point.x, point.y)
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


if location.search != '?offline'
  network = require './network'
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


# hacking here :/


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
  debug.update()
  ftm.update(dt)
  requestAnimationFrame(update)
requestAnimationFrame(update)