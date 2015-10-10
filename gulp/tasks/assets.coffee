gulp = require 'gulp'
connect = require 'gulp-connect'

gulp.task 'serve-assets', ->
  connect.server({
    port: 9002,
    root: ['../assets/']
  })
