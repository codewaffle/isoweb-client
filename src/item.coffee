SPRITE_LOCATION = './assets/'

class Item
  constructor: (id, name, quantity, weight, volume, sprite) ->
    @id = id
    @name = name || 'No Name'
    @description = 'No description.'
    @quantity = quantity || 1
    @sprite = SPRITE_LOCATION + sprite || './assets/sprites/bad_crate.png'
    @weight = weight || 0
    @volume = volume || 0
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

TEST_ITEMS = ->
  i = 0
  items = [
    new Item(i++, 'a flaming blade of slaying', 1, 1, 10, './assets/icons/weapon_blade.png'),
    new Item(i++, 'a club', 1, 1, 10, './assets/icons/weapon_club.png'),
    new Item(i++, 'a bow', 1, 1, 10, './assets/icons/weapon_bow.png'),
    new Item(i++, 'an axe', 1, 1, 10, './assets/icons/weapon_axe.png'),
    new Item(i++, 'a flaming blade of slaying', 5, 1, 10, './assets/icons/weapon_blade.png'),
    new Item(i++, 'a club', 50, 1, 10, './assets/icons/weapon_club.png'),
    new Item(i++, 'a bow', 500, 1, 10, './assets/icons/weapon_bow.png'),
    new Item(i++, 'an axe', 1000, 1, 10, './assets/icons/weapon_axe.png')
  ]

  return items

module.exports =
  Item: Item
  TEST_ITEMS: TEST_ITEMS