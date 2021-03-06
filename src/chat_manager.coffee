entity = require './entity'
entityController = require './entity_controller'

MSG_TYPE_CHAT = 0
MSG_TYPE_ACTION = 1

class ChatManager
  constructor: ->
    @buffer = []
    @isOpen = false

    @chatLogElement = document.createElement('div')
    @chatLogElement.className = 'chat-log'
    document.body.appendChild(@chatLogElement)

    @inputElement = document.createElement('input')
    @inputElement.className = 'chat-input'
    document.body.appendChild(@inputElement)
    @inputElement.style.display = 'none'

    me = @
    $(@inputElement).on('keydown', (ev) ->
      if ev.keyCode == 13 # enter
        msg = @value
        if msg.length > 0
          me.sendChat(msg)
        me.closeChat()
        ev.preventDefault()
        return false
    )

  openChat: ->
    # open input box
    @inputElement.style.display = 'block'
    @inputElement.focus()
    @isOpen = true

  closeChat: ->
    # close input box
    @inputElement.value = ''
    @inputElement.style.display = 'none'
    @inputElement.blur()
    @isOpen = false

  addChat: (name, text) ->
    # adds a chat message

    entry =
      type: MSG_TYPE_CHAT
      name: name
      text: text
      timestamp: Date.now()
    @buffer.push(entry)

    @chatLogElement.innerHTML += '<div class="entry"><span class="chat-from"><span class="entity">' + name +
        '</span> chats:</span><span class="chat-message">' + text + '</span></div>'

    # scroll to bottom
    @chatLogElement.scrollTop = @chatLogElement.scrollHeight


  addAction: (text) ->
    # adds an action message containing entity references (ids).
    # e.g. "{{ent:1}} salvages {{ent:2}} from {{ent:3}}." or
    #      "Foo salvages a bar from a destroyed baz."

    entry =
      type: MSG_TYPE_ACTION
      text: text
      timestamp: Date.now()
    @buffer.push(entry)

    # replace entity identifiers
    html = text.replace(/\{\{ent:[0-9]+}}/g, (value) ->
      id = value.split(':')[1]
      # look up entity
      ent = entity.get(id)
      return '<span class="entity" data-entity-id="' + id + '">' + ent.name + '</span>'
    )

    @chatLogElement.innerHTML += '<div class="entry">' + html + '</div>'

    # scroll to bottom
    @chatLogElement.scrollTop = @chatLogElement.scrollHeight

  sendChat: (text) ->
    if entityController.current?
      entityController.current.cmdChat(text)
    else
      main = require './main'
      main.floatingTextManager.floatText(text, null, 4000, 600)

module.exports =
  ChatManager: ChatManager