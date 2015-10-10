gulp = require 'gulp'
connect = require 'gulp-connect'
cors = require 'cors'

gulp.task 'connect', ->
  connect.server({
    port: 9000,
    root: ['dist']
  })
  connect.server({
    port: 9002,
    root: ['../assets/'],
    middleware: ->
      [cors()]
  })

gulp.task 'dev', ['connect', 'watch']

gulp.task 'external-dev', ['serve-assets', 'watch']