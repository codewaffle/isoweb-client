module.exports = {}
registry = module.exports.registry = {}

class EntityDef
  constructor: (@keyHash) ->
    @components = {}
    registry[@keyHash] = @

  update: (update_obj) ->
    for comp,compData of update_obj
      @components[comp] ?= {}

      for prop,propData of compData
        @components[comp][prop] = propData

module.exports.get = (keyHash) ->
  return registry[keyHash] or new EntityDef(keyHash)
