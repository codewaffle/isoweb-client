main = require './main'
Menu = require './menu'


class MenuManager
  constructor: ->
    @currentMenu = null

  showContextMenu: (items, entity) ->
    if !@currentMenu
      hideContextMenu()
    @currentMenu = new Menu(items, entity)
    @currentMenu.show(main.inputManager)

  hideContextMenu: () ->
    @currentMenu.hide()
    @currentMenu = null

module.exports =
  MenuManager: MenuManager