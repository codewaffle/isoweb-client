pixi = require 'pixi'

class GrassSprayEffect
  constructor: ->
    @particles = []
    textureUri = '/assets/particles/poof_color.png'
    @texture = new pixi.Texture.fromImage(textureUri)
    @container = new pixi.Container()
    @playing = false

    @particles = []
    for i in [0..5]
      particle =
        sprite: new pixi.Sprite(@texture)
        offsetx: (Math.random() - 0.5) * 128
        offsety: (Math.random() - 0.5) * 128
        dx: (Math.random() - 0.5)
        dy: (Math.random() - 0.5)
        rotation: (Math.random() - 0.5) * Math.PI
        scale: 2

      particle.sprite.anchor.set(0.5, 0.5)
      particle.sprite.scale.set(particle.scale, particle.scale)
      particle.sprite.position.set(particle.offsetx, particle.offsety)
      particle.sprite.rotation = particle.rotation
      @particles.push(particle)
      @container.addChild(particle.sprite)

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

    alpha = @ttl / @duration
    for p in @particles
      p.offsetx += p.dx
      p.offsety += p.dx
      p.sprite.position.set(p.offsetx, p.offsety)
      p.sprite.alpha = alpha

    return true

module.exports.GrassSprayEffect = GrassSprayEffect