pixi = require 'pixi'
config = require './config'

cache = {}
callbacks = {}

module.exports =
  getSprite: (path, cb) ->
    cb(new pixi.Sprite.fromImage(config.asset_base + path))
