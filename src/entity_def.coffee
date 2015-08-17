module.exports = {}
registry = module.exports.registry = {}

pixi = require 'pixi'
config = require './config'

class EntityDef
  constructor: (@keyHash) ->
    @components = {}

    # clientside attributes
    @attribCallbacks = {}
    @attribs = {}

    registry[@keyHash] = @

  update: (update_obj) ->
    for comp,compData of update_obj
      @components[comp] ?= {}

      for prop,propData of compData
        @components[comp][prop] = propData

    @postUpdate()

  postUpdate: ->
    if @components.Spine?
      loader = new pixi.loaders.Loader()
      loader.add(
        @keyHash, config.asset_base + @components.Spine.character
      ).load( (loader, resources) =>
        @asyncUpdate('spineCharacter', resources[@keyHash].spineData)
      )

  addAttribCallback: (attrib, func) ->
    if not @attribCallbacks[attrib]?
      @attribCallbacks[attrib] = [func]
    else
      if @attribCallbacks[attrib] is true
        # call immediately if we've already loaded
        func(@attribs[attrib])
      else
        # still loading, add to list
        @attribCallbacks[attrib].push(func)

  asyncUpdate: (attrib, value) ->
    if @attribCallbacks[attrib]?
      for func in @attribCallbacks[attrib]
        func(value)

    @attribCallbacks[attrib] = true
    @attribs[attrib] = value

module.exports.get = (keyHash) ->
  return registry[keyHash] or new EntityDef(keyHash)
