win = require './window'


class DebugWindow extends win.Window
  constructor: (windowManager) ->
    super(windowManager, 'debug-window', document.body.clientWidth - 324, 4)
    @entries = []
    @tableElement = document.createElement('table')
    @tableElement.className = 'debug-table'

    @domElement.appendChild(@tableElement)

  add: (key, fn) ->
    @entries.push
      key: key
      fn: fn
      lastValue: null
    @update()

  remove: (key) ->
    for i in [@entries.length-1..0]
      if @entries[i].key == key
        @entries.splice(i, 1)
    @update()

  update: ->
    isDirty = false
    html = ''
    for entry in @entries
      value = entry.fn().toString()
      html += '<tr><td>' + entry.key + ':</td><td>' + value + '</td></tr>'
      if value == entry.lastValue
        continue

      entry.lastValue = value
      isDirty = true

    if isDirty
      @tableElement.innerHTML = html

module.exports.DebugWindow = DebugWindow