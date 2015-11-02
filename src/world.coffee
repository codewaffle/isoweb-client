pixi = require 'pixi'

class World extends pixi.Container
  constructor: ->
    super()

module.exports = new World() # yes, we are exporting a singleton.