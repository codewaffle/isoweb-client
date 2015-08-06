baseWindow = require './window'
containerWindow = require './container_window'
debugWindow = require './debug_window'

WINDOWS = []

class WindowManager
  constructor: ->
    @draggingWindow = null
    @focusWindow = null
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
    if !win.canHaveFocus
      return

    if @focusWindow?
      @focusWindow.blur()
    @focusWindow = win
    win.domElement.classList.add('focus')
    win.domElement.style.zIndex = '1'

    # focus first input element
    els = win.domElement.getElementsByTagName('input')
    if els.length > 0
      els[0].focus()

  getVisibleWindows: ->
    list = []
    for w in WINDOWS
      if w.visible
        list.push(w)
    return list

  getLastWindow: ->
    list = @getVisibleWindows()
    return list[0] if list.length > 0

  showWindow: (win) ->
    win.domElement.style.display = 'block'
    win.visible = true
    return win

  hideWindow: (win) ->
    win.domElement.style.display = 'none'
    win.visible = false
    return win

  closeWindow: (win) ->
    if !win.canClose
      return

    if @focusWindow == win
      # focus new window
      @focusWindow = null
      for w in @getVisibleWindows().reverse()
        if w != win and w.canHaveFocus
          @setFocus(w)
          break
    @draggingWindow = null if @draggingWindow == win

    document.body.removeChild(win.domElement)
    @removeWindow(win)


module.exports =
  WindowManager: WindowManager