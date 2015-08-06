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

inputManager = new input.InputManager()
menuManager = new menu.MenuManager()
windowManager = new wm.WindowManager()

renderer = new pixi.autoDetectRenderer(1024, 1024)
renderer.backgroundColor = 0xAAFFCC

stage = new pixi.Container()

cam = new camera.Camera(renderer, stage)

document.body.appendChild(renderer.view)

document.addEventListener('contextmenu', (e) ->
  e.preventDefault()
  return false
)

document.addEventListener('mousedown', (e) ->
  # TODO : clicking on entities still fires this, but don't want to rely on clicking on the bg as it won't always be there.
  e.preventDefault()
  point = cam.screenToWorld(e.x, e.y)
  console.log point
  entityController.current.cmdMove(point.x, point.y)
  return false
)

bg = new pixi.extras.TilingSprite(
  pixi.Texture.fromImage(config.asset_base + 'tiles/tile_grass.png'), renderer.width, renderer.height)

cam.container.addChildAt(bg, 0)

resize = ->
  h = window.innerHeight
  w = window.innerWidth
  bg.width = w / stage.scale.x
  bg.height = h / stage.scale.y
  bg.position.x = -cam.container.position.x/stage.scale.x
  bg.position.y = -cam.container.position.y/stage.scale.y

# multiple resize handlers for now.. mostly for the hacked-in bg. bg will not always render this way.
window.addEventListener('resize', cam.onResize)
window.addEventListener('resize', resize)

cam.onResize()
resize()

module.exports =
  stage: stage
  inputManager: inputManager
  menuManager: menuManager
  windowManager: windowManager
  debugWindow: debug


if location.search != '?offline'
  network = require './network'
  conn = new network.Connection('ws://96.40.72.113:10000/player')
else
  # offline stuff goes here...

  # test container
  w = windowManager.createContainerWindow('test-container', null, 10, 10)
  w.show()
  w.updateContainer(item.TEST_ITEMS())


debug = windowManager.createDebugWindow()
debug.add('player pos', -> return if entityController.current? then entityController.current.ent.position else '-')


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
  requestAnimationFrame(update)
requestAnimationFrame(update)