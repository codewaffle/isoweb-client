effect = require './effect'
pixi = require 'pixi'

class FireEffect extends effect.Effect
  constructor: ->
    super('/assets/particles/poof.png', 8)

  createParticle: ->
    particle =
      offsetx: 0
      offsety: 0
      dx: Math.random() - 0.5
      dy: Math.random() - 0.5
      rotation: (Math.random() - 0.5) * Math.PI
      scale: 2
      duration: 500 + (Math.random() - 0.5) * 500
    super(particle)
    particle.sprite.tint = 0xff0000 + 0x100 * (0xff - Math.floor(0x10 * Math.random()))

  update: (dt) ->
    # replace any particles that have expired
    while @playing and @particles.length < @numParticles
      @createParticle()

    super(dt)

  updateParticle: (p, dt) ->
    p.offsetx += p.dx
    p.offsety += p.dy
    p.sprite.position.set(p.offsetx, p.offsety)
    p.sprite.alpha = p.ttl / p.duration
    p.scale += 0.02
    p.sprite.scale.set(p.scale, p.scale)
    super(p, dt)

module.exports.FireEffect = FireEffect