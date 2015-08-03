

class Item
  constructor: (id, name, quantity, weight, volume) ->
    @id = id
    @name = name || 'No Name'
    @description = 'No description.'
    @quantity = quantity || 1
    @iconURL = './assets/sprites/small_rock.png'
    @weight = weight || 10
    @volume = volume || 1
    @_items = []

    # events
    @onItemsUpdated = new Event('itemsUpdated')
    return @

  getTotalWeight: ->
    return @weight * @quantity

  getTotalVolume: ->
    return @volume * @quantity

  getItems: ->
    return @_items

  addItem: (item) ->
    @_items.push(item)
    @.dispatchEvent(@onItemsUpdated)

  removeItem: (id) ->
    for entry, i in @_items
      if entry.id == id
        @_items.splice(i, 1)
        @.dispatchEvent(@onItemsUpdated)

module.exports.Item = Item