pixi = require 'pixi'

class GrassSprayEffect
  constructor: ->
    @particles = []
    textureUri = '/assets/particles/leaf1_color.png'
    @texture = new pixi.Texture.fromImage(textureUri)
    @container = new pixi.ParticleContainer()
    @playing = false

    @particles = []
    for i in [0..5]
      particle =
        sprite: new pixi.Sprite(@texture)
        offsetx: Math.random()
        offsety: Math.random()
        dx: Math.random()
        dy: Math.random()
      @particles.push(particle)
      @container.addChild(particle)

  play: (@stage, x, y, @duration, @cb) ->
    @ttl = @duration
    @stage.addChild(@container)
    @container.position.set(x, y)
    @playing = true

  finished: ->
    @playing = false
    @stage.removeChild(@container)

    if @cb? then cb(@)

  update: (dt) ->
    @ttl -= dt
    if @ttl <= 0
      @finished()
      return false

    for p in @particles
      p.offsetx += p.dx
      p.offsety += p.dy
      p.sprite.position.set(p.offsetx, p.offsety)

    return true

module.exports.GrassSprayEffect = GrassSprayEffect