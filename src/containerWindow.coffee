gameWindow = require './window'

class ContainerWindow extends gameWindow.Window
  constructor: (ownerId, x, y) ->
    super(ownerId, x, y)

    @containerItems = []
    @layout = 'grid' # one of: 'table', 'grid'

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
    layoutButtons = @domElement.getElementsByClassName('toggle-container-layout')
    for button in layoutButtons
      _this = @
      button.addEventListener('click', ->
        value = if @.value == 'L' then 'table' else 'grid'
        _this.setLayout(value)
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
      tableHtml += '<tr class="container-item" id="container-item-id-' + item.id + '" data-item-id-"' + item.id + '">' +
      '<td class="item-name">' + item.name + '</td>' +
      '<td class="item-quantity">' + item.quantity + '</td>' +
      '<td class="item-weight">' + item.getTotalWeight() + ' kg</td>' +
      '<td class="item-volume">' + item.getTotalVolume() + ' ltr</td></tr>'

      # grid entry
      gridHtml += '<div class="container-item" id="container-item-id-' + item.id + '" data-item-id-"' + item.id +
        '" style="background-image: url(\'' + item.iconURL + '\')"></div>'

    @domContainerTableElement.innerHTML = tableHtml
    @domContainerGridElement.innerHTML = gridHtml


# toggle button handlers

module.exports.ContainerWindow = ContainerWindow