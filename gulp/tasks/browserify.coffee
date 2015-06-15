gulp = require 'gulp'
browserify = require 'browserify'
watchify = require 'watchify'
source = require 'vinyl-source-stream'
gutil = require 'gulp-util'

bundler = browserify
  entries: ['./src/main.coffee']
  extensions: ['.coffee']
  debug: true
  cache: {}
  packageCache: {}
  fullPaths: true

bundler.transform('coffeeify')


# i don't really know what's going on here but i'll figure it out someday...
bundle = (_bundler) ->
  b = ->
    _bundler
    .bundle()
    .pipe(source('main.js'))
    .pipe(gulp.dest('dist/js'))
  return b()


gulp.task 'browserify', ->
  bundle(bundler)


gulp.task 'browserify-watch', ->
  watcher = watchify(bundler)
  watcher.on 'update', -> bundle(watcher)
  watcher.on 'log', gutil.log
  bundle(watcher)
