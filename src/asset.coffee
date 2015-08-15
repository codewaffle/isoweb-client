pixi = require 'pixi'
config = require './config'

cache = {}
callbacks = {}

module.exports =
  getSprite: (path, cb) ->
    pepsi = new pixi.Sprite.fromImage(config.asset_base + path)
    pepsi.texture.baseTexture.mipmap = true
    cb(pepsi)
