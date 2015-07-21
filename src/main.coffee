three = require 'three'
input = require './input'

module.exports.scene = scene = new three.Scene()

camera = new three.PerspectiveCamera(
  75,
  window.innerWidth/window.innerHeight,
  0.1,
  1000.0)

camera.position.z = 30
renderer = new three.WebGLRenderer()
renderer.setSize(window.innerWidth, window.innerHeight)
document.body.appendChild(renderer.domElement)


light0 = new three.DirectionalLight(0xffffff, 1)
light0.castShadow = true
light0.shadowCameraVisible=true
light0.shadowMapWidth = 1024
light0.shadowMapHeight = 1024
light0.shadowCameraNear = 1
light0.shadowCameraFar = 100

light0.shadowCameraLeft = -20
light0.shadowCameraRight = 20
light0.shadowCameraTop = 20
light0.shadowCameraBottom = -20
light0.position.set(-60, 20, 100)  # this is actually direction on directional lights.

scene.add(light0)

pl = new three.PlaneGeometry(1000, 1000)
mat = new three.MeshPhongMaterial({color: 0x88ddaa})
o = new three.Mesh(pl, mat)
o.castShadow = false
o.receiveShadow = true

scene.add(o)

inputManager = new input.InputManager(camera)

# at one point there were fixed timesteps for processing - the time will come again.
DT = 1/60

network = require './network'
conn = new network.Connection('ws://96.40.72.113:10000/player')

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