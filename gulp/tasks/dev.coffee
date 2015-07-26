gulp = require 'gulp'
connect = require 'gulp-connect'

gulp.task 'connect', ->
  connect.server({
    port: 9000,
    root: ['dist', '../']
  })

gulp.task 'dev', ['connect', 'watch']
