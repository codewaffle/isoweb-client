three = require 'three'
config = require './config'

cache = {}
callbacks = {}
jsonLoader = new three.JSONLoader()
texLoader = new three.TextureLoader()

module.exports =
  getGeom: (path, cb) ->
    if not cache[path]?
      if callbacks[path]?
        callbacks[path].push(cb)
      else
        callbacks[path] = [cb]
        jsonLoader.load(
          config.asset_base + path,
          (geom, materials) ->
            cache[path] = geom
            for callback in callbacks[path]
              callback(geom)
            delete callbacks[path]
          )

    else
      cb(cache[path])

  getTexture: (path, cb) ->
    if not cache[path]?
      if callbacks[path]?
        callbacks[path].push(cb)
      else
        callbacks[path] = []
        texLoader.load(
          config.asset_base + path,
          (tex) ->
            cache[path] = tex
            for callback in callbacks[path]
              callback(tex)
            delete callbacks[path]
        )
    else
      cb(cache[path])
