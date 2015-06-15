fs = require 'fs'

tasks = fs.readdirSync('./gulp/tasks')

tasks.forEach (task) ->
  require './tasks/' + task
