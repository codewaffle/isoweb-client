three = require 'three'

module.exports = class Entity extends three.Object3D
  constructor: ->
    super()
    @attributes = {}
    @attributeTypes = {}

  setAttribute: (name, aType, val) ->
    @attributes[name] = val
    @attributeTypes[name] = aType
    this['set_' + name]?(val)
