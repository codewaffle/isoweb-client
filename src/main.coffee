pixi = require 'pixi'
input = require './input'
entity = require './entity'

# inputManager = new input.InputManager()
renderer = new pixi.autoDetectRenderer(128, 128)
renderer.backgroundColor = 0xAAFFCC
module.exports.stage = stage = new pixi.Container()
stage.scale.x = 1/3.0
stage.scale.y = 1/3.0
document.body.appendChild(renderer.view)

document.addEventListener('contextmenu', (e) ->
  e.preventDefault()
  return false
)

resize = ->
  h = window.innerHeight
  w = window.innerWidth
  stage.position.y = h/2
  stage.position.x = w/2
  renderer.resize(w, h)
window.addEventListener('resize', resize)
resize()

network = require './network'
conn = new network.Connection('ws://96.40.72.113:10000/player')



update = ->
  entity.update()
  renderer.render(stage)
  requestAnimationFrame(update)
requestAnimationFrame(update)

