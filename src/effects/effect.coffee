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

  createParticle: (particle) ->
    if not particle?
      console.error 'Particle must be created in subclass before calling base createParticle'
      return

    # base particle properties
    #   offsetx - x offset
    #   offsety - y offset
    #   rotation - sprite rotation in radians
    #   scale - sprite scale
    #   duration - how long particle should live (ttl)
    particle.ttl = particle.duration = particle.duration or @duration
    particle.sprite = new pixi.Sprite(@texture)
    particle.sprite.anchor.set(0.5, 0.5)
    particle.sprite.scale.set(particle.scale or 1, particle.scale or 1)
    particle.sprite.position.set(particle.offsetx or 0, particle.offsety or 0)
    particle.sprite.rotation = particle.rotation or 0
    @particles.push(particle)
    @container.addChild(particle.sprite)

  removeParticle: (particle) ->
    @container.removeChild(particle.sprite)
    for i in [@particles.length-1..0] by -1
      if @particles[i] == particle
        @particles.splice(i, 1)

  updateParticle: (particle, dt) ->
    particle.ttl -= dt
    if particle.ttl <= 0
      @removeParticle(particle)

  play: (@stage, x, y, @duration, @onComplete) ->
    if not @initialized
      return

    @ttl = @duration
    @stage.addChild(@container)
    @container.position.set(x, y)
    @playing = true

    # create initial particles
    for i in [0..@numParticles-1]
      @createParticle()
    return @

  stop: ->
    @finished()

  finished: ->
    @playing = false
    # container is removed once all particles are done playing
    #@stage.removeChild(@container)

    if @onComplete? then onComplete(@)

  update: (dt) ->
    if not @initialized
      return false

    # duration <= 0 plays indefinitely
    if @duration > 0 and @playing
      @ttl -= dt
      if @ttl <= 0
        @finished()

    if not @playing and @particles.length == 0
      return false

    for i in [@particles.length-1..0] by -1
      @updateParticle(@particles[i], dt)

    return true

module.exports.Effect = Effect