three = require 'three'

playerMap = three.ImageUtils.loadTexture('/assets/player.png')
playerMaterial = new three.SpriteMaterial({map: playerMap})

module.exports = class Player extends three.Sprite
  constructor: ->
    super(playerMaterial)
