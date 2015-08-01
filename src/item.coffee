class Item {
  constructor: ->
    @type = null
    @name = 'No Name'
    @description = 'No description.'
    @quantity = 1
    @iconURL = './assets/sprites/small_rock.png'
    @weight = 5
    @volume = 50
    @_items = []

    # events
    @onItemsUpdated = new Event('itemsUpdated')
    return @

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
        