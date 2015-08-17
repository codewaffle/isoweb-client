menu = require './menu'
main = require './main'

class MenuManager
  constructor: ->
    @currentMenu = null

  showContextMenu: (menuId, items) ->
    if @currentMenu
      @hideContextMenu()

    pos = require('./main').inputManager.mousePos
    @currentMenu = new menu.Menu(menuId, items)
    @currentMenu.show(pos.x, pos.y)

  hideContextMenu: ->
    if @currentMenu
      @currentMenu.hide()
      @currentMenu = null


module.exports =
  MenuManager: MenuManager