gameWindow = require './window'

class ContainerWindow extends gameWindow.Window
  constructor: (ownerId, x, y) ->
    super(ownerId, x, y)

    @containerItems = []

    # create container elements
    @domContainerElement = document.createElement('table')
    @domContainerElement.className = 'container ui'
    @domElement.innerHTML = """<div class="toolbar">
<div class="left">
  <input type="button" class="toggle active" name="container-layout" value="L" />
  <input type="button" class="toggle" name="container-layout" value="G" />
</div>
<div class="right">
  <input type="text" class="filter"></input>
</div>
</div>"""
    @domElement.appendChild(@domContainerElement)

    # TODO: subscribe to entity updates

    @updateContainer()

  updateContainer: (items) ->
    @containerItems = items || []
    html = """<tr class="container-header">
  <th class="item-name">Name</th>
  <th class="item-quantity">Qty</th>
  <th class="item-weight">Weight</th>
  <th class="item-volume">Volume</th>
</tr>"""

    for item in @containerItems
      html += '<tr class="container-item" id="container-item-id-' + item.id + '" data-item-id-"' + item.id + '">' +
      '<td class="item-name">' + item.name + '</td>' +
      '<td class="item-quantity">' + item.quantity + '</td>' +
      '<td class="item-weight">' + item.getTotalWeight() + ' kg</td>' +
      '<td class="item-volume">' + item.getTotalVolume() + ' ltr</td></tr>'

    @domContainerElement.innerHTML = html

module.exports.ContainerWindow = ContainerWindow