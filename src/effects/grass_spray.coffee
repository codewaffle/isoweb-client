effect = require './effect'
pixi = require 'pixi'

class GrassSprayEffect extends effect.Effect
  constructor: ->
    super('/assets/particles/grass1_color.png', 8)

  createParticle: ->
    particle =
      offsetx: (Math.random() - 0.5) * 128
      offsety: (Math.random() - 0.5) * 128
      dx: Math.random()
      dy: Math.random()
      rotation: (Math.random() - 0.5) * Math.PI
      scale: 1

    particle.dx *= if particle.offsetx > 0 then 1 else -1
    particle.dy *= if particle.offsety > 0 then 1 else -1
    super(particle)

  update: (dt) ->
    @alpha = @ttl / @duration
    super(dt)

  updateParticle: (p, dt) ->
    p.offsetx += p.dx
    p.offsety += p.dy
    p.sprite.position.set(p.offsetx, p.offsety)
    p.sprite.alpha = @alpha
    super(p, dt)

module.exports.GrassSprayEffect = GrassSprayEffect