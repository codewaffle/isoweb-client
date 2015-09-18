class ComponentBase
  updateData: (data) ->
    console.log @, 'updateData', data

module.exports =
  ComponentBase: ComponentBase