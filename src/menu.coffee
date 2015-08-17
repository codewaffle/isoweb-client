entity = require './entity'
entityController = require './entity_controller'


class Menu
  constructor: (@menuId, @items) ->
    @domElement = null

  show: (x, y) ->
    # create DOM element
    @domElement = document.createElement('div')
    @domElement.className = 'menu'
    for item in @items
      @domElement.innerHTML += '<li data-menu-id="'+@menuId+'" data-command="' + item[0] + '">' + item[1] + '</li>'

    document.body.appendChild(@domElement)

    # add event handler
    $(@domElement).on('click', (ev) ->
      target = ev.target || ev.srcElement
      menuId = target.getAttribute('data-menu-id')
      cmd = target.getAttribute('data-command')
      if menuId && cmd
        entityController.current.cmdMenuExec(menuId, cmd)
    )

    # set position
    @domElement.style.left = x + 'px'
    @domElement.style.top = y + 'px'

  hide: ->
    document.body.removeChild(@domElement)

module.exports.Menu = Menu