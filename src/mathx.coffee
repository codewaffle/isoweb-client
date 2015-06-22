class RNG
  constructor: (@seed) ->
    if not @seed?
      @seed = Math.floor(Math.random() * Math.pow(2,32))

  rand01: ->
    @seed = (@seed * 9301 + 49297) % 233280
    return @seed/233280

  randInt: (a, b) ->
    max = b or a or Math.pow(2,32)
    min = if b then a else 0

    return Math.floor(min + (@rand01() * (max - min)))

module.exports =
  RNG: RNG