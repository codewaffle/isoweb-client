pixi = require 'pixi'

class Effect
  constructor: (@textureUri, @numParticles) ->
    if not @textureUri? or not @numParticles?
      console.error 'Effect must be constructed with a texture URI and particle count'
      return

    @initialized = true
    @particles = []
    @texture = new pixi.Texture.fromImage(@textureUri)
    @container = new pixi.Container()
    @playing = false

    @particles = []
    for i in [0..@numParticles-1]
      particle = @createParticle()
      particle.sprite.anchor.set(0.5, 0.5)
      particle.sprite.scale.set(particle.scale, particle.scale)
      particle.sprite.position.set(particle.offsetx, particle.offsety)
      particle.sprite.rotation = particle.rotation
      @particles.push(particle)
      @container.addChild(particle.sprite)

  createParticle: ->
    # overloaded by inheriting classes

    # particle definition:
    #   offsetx - x offset
    #   offsety - y offset
    #   dx - change in x offset per update
    #   dy - change in y offset per update
    #   rotation - sprite rotation in radians
    #   scale - sprite scale

  updateParticle: (particle, dt) ->
    # overloaded by inheriting class

  play: (@stage, x, y, @duration, @cb) ->
    if not @initialized
      return

    @ttl = @duration
    @stage.addChild(@container)
    @container.position.set(x, y)
    @playing = true

  finished: ->
    @playing = false
    @stage.removeChild(@container)

    if @cb? then cb(@)

  update: (dt) ->
    if not @initialized
      return false

    if @duration > 0
      @ttl -= dt
      if @ttl <= 0
        @finished()
        return false

    for p in @particles
      @updateParticle(p, dt)

    return true

module.exports.Effect = Effect