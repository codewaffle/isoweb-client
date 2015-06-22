
class Viewport
  constructor: ->
    @renderer = new three.WebGLRenderer()
    @resize(window.innerWidth, window.innerHeight)

  resize: (w, h) ->
    @renderer.setSize(w, h)



module.exports.Viewport = Viewport