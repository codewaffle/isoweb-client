gulp = require 'gulp'
connect = require 'gulp-connect'
cors = require 'cors'

gulp.task 'serve-assets', ->
  connect.server({
    port: 9002,
    root: ['../assets/'],
    middleware: ->
      [cors()]
  })
