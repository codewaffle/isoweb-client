class ComponentBase
  constructor: (@ent) ->

  updateData: (data) ->
    for key of data
      @[key] = data[key]

  enable: ->
  disable: ->

module.exports =
  ComponentBase: ComponentBase