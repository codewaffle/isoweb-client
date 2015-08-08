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
    @itemHoverWindow = null
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

  beginDragItem: (win, itemElement, x, y) ->
    #@draggingItem = itemElement
    id = itemElement.getAttribute('data-item-id')
    item = win.findItemById(Number(id))
    @draggingItem = item

    # create cursor element for drag effect
    el = document.createElement('div')
    el.classList.add('cursor-item')
    rect = itemElement.getBoundingClientRect()

    el.innerHTML = '<p>' + item.name + '</p>'
    document.body.appendChild(el)
    @cursorElement = el
    @dragItemUpdate(x, y)

  endDragItem: ->
    @draggingItem = null
    if @cursorElement?
      document.body.removeChild(@cursorElement)
    @cursorElement = null
    if @itemHoverWindow?
      @endItemHover()

  dragItemUpdate: (x, y) ->
    @cursorElement.style.left = x + 'px'
    @cursorElement.style.top = y + 'px'

  dropItem: (x, y) ->
    # TODO: do network stuffs

    w = @getAtCoordinates(x, y)
    if w?
      # see if we're dropping on a different container window
      if w.ownerId != @draggingItem.ownerId and Array.isArray(w.containerItems)
        console.log('item (%o) dropped on "%s" (%o)', @draggingItem, @itemHoverWindow.name, @itemHoverWindow)
      else
        console.log('item (%o) dropped on invalid window (%o)', @draggingItem, w)
    else
      console.log('item (%o) dropped at (%d, %d)', @draggingItem, x, y)

    @endDragItem()

  beginItemHover: (win) ->
    if win == @itemHoverWindow
      return

    if @itemHoverWindow
      @endItemHover()
    @itemHoverWindow = win
    @itemHoverWindow.domElement.classList.add('item-hovering')

  endItemHover: ->
    @itemHoverWindow.domElement.classList.remove('item-hovering')
    @itemHoverWindow = null

  # utility functions

  #getWindowByChildElement: (el) ->
  #  # walk hierarchy until we find a window or null
  #  while el? and !el.classList.contains('window')
  #    el = el.parentElement
  #  return el


module.exports =
  WindowManager: WindowManager