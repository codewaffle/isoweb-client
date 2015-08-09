entity = require './entity'

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
    @inputElement.addEventListener('keydown', (ev) ->
      if ev.keyCode == 13 # enter
        msg = @value
        if msg.length > 0
          me.sendMessage(msg)
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

  addMessage: (entId, msg) ->
    if entId >= 0
      ent = entity.get(entId)
      if ent?
        name = ent.name
      else
        console.error('Chat message received from invalid entity "%d".', entId)
        return
    else
      name = 'Server'

    @buffer.push
      entId: entId,
      name: name,
      msg: msg

    @chatLogElement.innerHTML += '<div class="entry"><span class="from">' + name +
        '</span><span class="message">' + msg + '</span></div>'

    # scroll to bottom
    @chatLogElement.scrollTop = @chatLogElement.scrollHeight


  sendMessage: (msg) ->
    # TODO : send message to server...
    # add message directly to log for testing purposes
    @addMessage(-1, msg)

module.exports =
  ChatManager: ChatManager