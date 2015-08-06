baseWindow = require './window'
containerWindow = require './container_window'
debugWindow = require './debug_window'

WINDOWS = []

class WindowManager
  constructor: ->
    # nothing to do...
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
    for w in WINDOWS
      rect = w.domElement.getBoundingClientRect()
      if w.visible and (rect.left <= x and x <= rect.right) and (rect.top <= y and y <= rect.bottom)
        return w
    return null

  addWindow: (win) ->
    # add window to global list
    WINDOWS.push(win)

  removeWindow: (win) ->
    # remove window from global list
    for i in [WINDOWS.length-1..0]
      if WINDOWS[i] is win
        WINDOWS.splice(i, 1)

module.exports =
  WindowManager: WindowManager