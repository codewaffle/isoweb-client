class ComponentBase
  constructor: (@ent) ->

  updateData: (data) ->
    for key of data
      @[key] = data[key]

  enable: ->
  disable: ->

class EchoBase extends ComponentBase
  updateData: (data) ->
    super(data)
    console.log("Unhandled Component Data: ", data)

module.exports =
  ComponentBase: ComponentBase
  EchoBase: EchoBase