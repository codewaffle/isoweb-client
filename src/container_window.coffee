gameWindow = require './window'

class ContainerWindow extends gameWindow.Window
  constructor: (ownerId, x, y) ->
    super(ownerId, x, y)

    @containerItems = []
    @layout = 'grid' # one of: 'table', 'grid'
    @selectedItemIds = [] # entity ids
    @selectedItems = [] # DOM elements

    # create container elements
    @domContainerTableElement = document.createElement('table')
    @domContainerTableElement.className = 'container table ui'
    @domContainerGridElement = document.createElement('div')
    @domContainerGridElement.className = 'container grid ui'
    @domElement.innerHTML = """<div class="toolbar">
<div class="left">
  <input type="button" class="toggle toggle-container-layout" value="L" />
  <input type="button" class="toggle toggle-container-layout active" value="G" />
</div>
<div class="right">
  <input type="text" class="filter"></input>
</div>
</div>"""
    @domElement.appendChild(@domContainerTableElement)
    @domElement.appendChild(@domContainerGridElement)

    # event handlers
    _this = @
    layoutButtons = @domElement.getElementsByClassName('toggle-container-layout')
    for button in layoutButtons
      button.addEventListener('click', ->
        value = if @.value == 'L' then 'table' else 'grid'
        _this.setLayout(value)
      )

    @domContainerGridElement.addEventListener('click', (ev) ->
      if ev.target is null then return
      el = ev.target

      # get container element in case child element was clicked
      while !el.classList.contains('container-item')
        el = el.parentElement
        if el is null then return

      if !ev.ctrlKey
        _this.deselectItems()
      _this.selectItems([el.getAttribute('data-item-id')])
    )

    @domContainerTableElement.addEventListener('click', (ev) ->
      if ev.target is null then return
      el = ev.target

      # get container element in case child element was clicked
      while !el.classList.contains('container-item')
        el = el.parentElement
        if el is null then return

      if !ev.ctrlKey
        _this.deselectItems()
      _this.selectItems([el.getAttribute('data-item-id')])
    )

    @setLayout(@layout)

    # TODO: subscribe to entity updates

    @updateContainer()

  setLayout: (value) ->
    @layout = value

    # update layout buttons
    layoutButtons = @domElement.getElementsByClassName('toggle-container-layout')
    for button in layoutButtons
      button.classList.remove('active')
      if (button.value == 'L' and value == 'table') or (button.value == 'G' and value == 'grid')
        button.classList.add('active')

    # update container visibility
    if @layout == 'table'
      @domContainerTableElement.style.display = 'table'
      @domContainerGridElement.style.display = 'none'
    else
      @domContainerTableElement.style.display = 'none'
      @domContainerGridElement.style.display = 'block'

  updateContainer: (items) ->
    @containerItems = items || []

    gridHtml = ''

    # table header
    tableHtml = """<tr class="container-header">
  <th class="item-name">Name</th>
  <th class="item-quantity">Qty</th>
  <th class="item-weight">Weight</th>
  <th class="item-volume">Volume</th>
</tr>"""

    for item in @containerItems
      # table entry
      tableHtml += '<tr class="container-item" data-item-id="' + item.id + '">' +
      '<td class="item-name">' + item.name + '</td>' +
      '<td class="item-quantity">' + item.quantity + '</td>' +
      '<td class="item-weight">' + item.getTotalWeight() + ' kg</td>' +
      '<td class="item-volume">' + item.getTotalVolume() + ' ltr</td></tr>'

      # grid entry
      gridHtml += '<div class="container-item" data-item-id="' + item.id +
          '"><div class="item-icon" style="background-image: url(\'' + item.iconURL +
          '\')"><span class="item-quantity">'
      if item.quantity > 1
        gridHtml += 'x' + item.quantity
      gridHtml += '</span></div><span class="item-name">' + item.name + '</span></div>'

    @domContainerTableElement.innerHTML = tableHtml
    @domContainerGridElement.innerHTML = gridHtml

  deselectItems: (ids) ->
    # remove ids
    if ids is undefined
      @selectedItemIds = []
    else
      for i in [@selectedItemIds.length-1..0] by -1
        if @selectedItemIds[i] in ids
          @selectedItemIds.pop()

    # remove elements
    for i in [@selectedItems.length-1..0] by -1
      if ids is undefined or @selectedItems[i].getAttribute('data-item-id') in ids
        @selectedItems.pop().classList.remove('selected')

  selectItems: (ids) ->
    # add grid elements
    for el in @domContainerGridElement.getElementsByTagName('div')
      if el.classList.contains('container-item')
        id = el.getAttribute('data-item-id')
        if id in ids and id not in @selectedItemIds
          el.classList.add('selected')
          @selectedItems.push(el)

    # add list elements
    for el in @domContainerTableElement.getElementsByTagName('tr')
      if el.classList.contains('container-item')
        id = el.getAttribute('data-item-id')
        if id in ids and id not in @selectedItemIds
          el.classList.add('selected')
          @selectedItems.push(el)

    # add ids
    for id in ids
      if id not in @selectedItemIds
        @selectedItemIds.push(id)

module.exports.ContainerWindow = ContainerWindow