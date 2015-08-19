module.exports = {}
registry = module.exports.registry = {}

pixi = require 'pixi'
config = require './config'

spineRegistry = {}

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
    # runs after all update data has been applied, used to do extra processing to prepare assets for use

    if @components.Spine?
      if spineRegistry[@components.Spine.character]?
        @asyncUpdate('spineCharacter', spineRegistry[@components.Spine.character])
      else
        loader = new pixi.loaders.Loader()
        loader.add(
          @keyHash, config.asset_base + @components.Spine.character
        ).load( (loader, resources) =>
          spineRegistry[@components.Spine.character] = resources[@keyHash].spineData
          @asyncUpdate('spineCharacter', resources[@keyHash].spineData)
        )

    if @components.Structure?
      console.log @components.Structure
      console.log "Use tileset #{@components.Structure.tileset} to render a #{@components.Structure.size[0]}x#{@components.Structure.size[1]} grid containing #{@components.Structure.data} where 0 is empty space, 1 is wall and 2 is floor"

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
