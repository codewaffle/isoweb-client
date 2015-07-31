
class Menu
  constructor: (items, entity) ->
    @items = items
    @entity = entity
    @domElement = null

  show: (x, y) ->
    # create DOM element
    @domElement = document.createElement('div')
    for item in items
      @domElement.innerHTML += '<li data-command="' + item[0] + '">' + item[1] + '</li>'

    document.body.appendChild(@domElement)

    # set position
    @domElement.style.left = x + 'px'
    @domElement.style.top = y + 'px'