pixi = require 'pixi'

pixi.Point.prototype.toString = -> return '(' + @.x.toFixed(2) + ', ' + @.y.toFixed(2) + ')'