three = require 'three'
input = require './input'

scene = new three.Scene()

camera = new three.PerspectiveCamera(
  75,
  window.innerWidth/window.innerHeight,
  0.1,
  1000.0)

camera.position.z = 10
renderer = new three.WebGLRenderer()
renderer.setSize(window.innerWidth, window.innerHeight)
document.body.appendChild(renderer.domElement)

light0 = new three.DirectionalLight(0xffffff, 0.3)
light0.position.set(0, 0, 1)  # this is actually direction on directional lights.

scene.add(light0)

inputManager = new input.InputManager(camera)

# at one point there were fixed timesteps for processing - the time will come again.
DT = 1/60

network = require './network'
conn = new network.Connection('ws://127.0.0.1:10000/player')

document.addEventListener(
  'mousedown',
  (evt) ->
    conn.sendMoveTo(inputManager.mousePos.x, inputManager.mousePos.y)
  ,false
)

render = ->
  requestAnimationFrame(render)
  inputManager.update(DT)
  renderer.render(scene, camera)

render()