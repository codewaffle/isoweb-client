gulp = require 'gulp'
connect = require 'gulp-connect'

gulp.task 'connect', ->
  connect.server({
    root: ['dist', '../']
  })

gulp.task 'dev', ['connect', 'watch']
