entity = require './entity'
entityController = require './entity_controller'


class Menu
  constructor: (items, entityId) ->
    @items = items
    @entityId = entityId
    @domElement = null

  show: (x, y) ->
    # create DOM element
    @domElement = document.createElement('div')
    @domElement.className = 'menu'
    for item in @items
      @domElement.innerHTML += '<li data-entity-id="'+@entityId+'" data-command="' + item[0] + '">' + item[1] + '</li>'

    document.body.appendChild(@domElement)

    # add event handler
    @domElement.addEventListener('click', (e) ->
      target = e.target || e.srcElement
      entityId = target.getAttribute('data-entity-id')
      cmd = target.getAttribute('data-command')
      if entityId && cmd
        entity = entity.get(entityId)
        entityController.current.cmdMenuExec(entity, cmd)
    )

    # set position
    @domElement.style.left = x + 'px'
    @domElement.style.top = y + 'px'

  hide: ->
    document.body.removeChild(@domElement)

module.exports.Menu = Menu