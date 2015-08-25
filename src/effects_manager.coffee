class EffectsManager
  constructor: (@stage, @camera) ->
    @instances = []

  playEffect: (effect, x, y, duration, cb) ->
    @instances.push(effect)
    effect.play(@stage, x, y, duration, cb)

  update: (dt) ->
    for i in [@instances.length-1..0] by -1
      instance = @instances[i]
      if not instance.update(dt)
        @instances.splice(i, 1)

module.exports.EffectsManager = EffectsManager