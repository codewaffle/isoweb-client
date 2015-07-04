three = require 'three'
Entity = require './entity'

class SimpleMesh extends Entity

class SimpleSprite extends Entity
  set_sprite: (val) ->
    @spriteMap = three.ImageUtils.loadTexture('/assets/' + val)
    @material = new three.SpriteMaterial(
      map: @spriteMap
      color: 0xffffff
    )
    @sprite = new three.Sprite(@material)

    @add(@sprite)

module.exports =
  SimpleMesh: SimpleMesh
  SimpleSprite: SimpleSprite