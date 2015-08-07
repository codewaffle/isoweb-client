baseWindow = require './window'
containerWindow = require './container_window'
debugWindow = require './debug_window'

WINDOWS = []

class WindowManager
  constructor: ->
    @draggingWindow = null
    @focusWindow = null
    @draggingItem = null
    @cursorElement = null
    return @

  createWindow: (name, x, y) ->
    w = new baseWindow.Window(@, name, x, y)
    @addWindow(w)
    return w

  createContainerWindow: (name, ownerId, x, y) ->
    w = new containerWindow.ContainerWindow(@, name, ownerId, x, y)
    @addWindow(w)
    return w

  createDebugWindow: ->
    w = new debugWindow.DebugWindow(@)
    @addWindow(w)
    return w

  getByName: (name) ->
    for w in WINDOWS
      if w.name == name
        return w
    return null

  getByOwner: (id) ->
    for w in WINDOWS
      if w.ownerId == id
        return w
    return null

  getAtCoordinates: (x, y) ->
    # return visible window containing coordinates
    list = []
    for w in WINDOWS
      rect = w.domElement.getBoundingClientRect()
      if w.visible and (rect.left <= x and x <= rect.right) and (rect.top <= y and y <= rect.bottom)
        # give priority to focus window
        if w == @focusWindow
          return w
        list.push(w)

    return list[0] if list.length > 0

  addWindow: (win) ->
    # add window to global list
    WINDOWS.push(win)

  removeWindow: (win) ->
    # remove window from global list
    for i in [WINDOWS.length-1..0]
      if WINDOWS[i] is win
        WINDOWS.splice(i, 1)

  beginDrag: (win, x, y) ->
    @draggingWindow = win
    win.beginDrag(x, y)
    #console.log('begin drag %s offset %d, %d', win.name, x, y)

  endDrag: () ->
    win = @draggingWindow
    @draggingWindow = null
    win.endDrag()
    #console.log('end drag %s', win.name)

  dragUpdate: (x, y) ->
    # apply offset
    x = x - @draggingWindow.dragOffset.x
    y = y - @draggingWindow.dragOffset.y
    @draggingWindow.setPosition(x, y)
    #console.log('dragging to %d, %d', x, y)

  setFocus: (win) ->
    if win == @focusWindow
      return

    if @focusWindow?
      @focusWindow.blur()
    @focusWindow = win
    win.focus()

  beginDragItem: (win, itemElement) ->
    @draggingItem = itemElement
    # create cursor element for drag effect
    el = document.createElement('div')
    el.classList.add('cursor-item')
    rect = itemElement.getBoundingClientRect()
    el.style.left = rect.left + 'px'
    el.style.top = rect.top + 'px'

    id = itemElement.getAttribute('data-item-id')
    item = win.findItemById(Number(id))
    el.innerHTML = '<p>' + item.name + '</p>'
    document.body.appendChild(el)
    @cursorElement = el

  endDragItem: ->
    @draggingItem = null
    if @cursorElement?
      document.body.removeChild(@cursorElement)
    @cursorElement = null

  dragItemUpdate: (x, y) ->
    @cursorElement.style.left = x + 'px'
    @cursorElement.style.top = y + 'px'

  dropItem: (x, y) ->
    # TODO: make sure we dropped the item in a valid location, then do something with it

    @endDragItem()

module.exports =
  WindowManager: WindowManager