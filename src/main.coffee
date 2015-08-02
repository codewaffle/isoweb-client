pixi = require 'pixi'
input = require './input'
entity = require './entity'
config = require './config'
menu = require './menu_manager'
gameWindow = require './window'
container = require './containerWindow'
item = require './item'

inputManager = new input.InputManager()

menuManager = new menu.MenuManager()

renderer = new pixi.autoDetectRenderer(128, 128)
renderer.backgroundColor = 0xAAFFCC

stage = new pixi.Container()
stage.scale.x = 1/3.0
stage.scale.y = 1/3.0

document.body.appendChild(renderer.view)

document.addEventListener('contextmenu', (e) ->
  e.preventDefault()
  return false
)

bg = new pixi.extras.TilingSprite(
  pixi.Texture.fromImage(config.asset_base + 'tiles/tile_grass.png'), renderer.width, renderer.height)
stage.addChild(bg)


resize = ->
  h = window.innerHeight
  w = window.innerWidth
  bg.width = w / stage.scale.x
  bg.height = h / stage.scale.y
  stage.position.y = h/2
  stage.position.x = w/2
  bg.position.x = -stage.position.x/stage.scale.x
  bg.position.y = -stage.position.y/stage.scale.y

  renderer.resize(w, h)
window.addEventListener('resize', resize)
resize()

network = require './network'
#conn = new network.Connection('ws://96.40.72.113:10000/player')

module.exports =
  stage: stage
  inputManager: inputManager
  menuManager: menuManager


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

stage.filters = [bla]

update = ->
  entity.update()
  renderer.render(stage)
  requestAnimationFrame(update)
requestAnimationFrame(update)

w = new container.ContainerWindow(null, 10, 10)
w.show()
w.updateContainer([
  new item.Item('wood', 1000),
  new item.Item('rocks', 9999)
  new item.Item('a meat popcicle')
  new item.Item('a MULTIPASS&trade; for "Leeloo Dallas"')
])