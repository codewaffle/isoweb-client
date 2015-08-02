gulp = require 'gulp'
browserify = require 'browserify'
watchify = require 'watchify'
source = require 'vinyl-source-stream'
gutil = require 'gulp-util'
coffeelint = require 'gulp-coffeelint'
merge = require 'merge-stream'
watch = require 'gulp-watch'
less = require 'gulp-less'
plumber = require 'gulp-plumber'

coffeelintOpts =
  max_line_length:
    value: 120

bundler = browserify
  entries: ['./src/main.coffee']
  extensions: ['.coffee']
  debug: true
  cache: {}
  packageCache: {}
  fullPaths: true

bundler.transform('coffeeify')


# i don't really know what's going on here but i'll figure it out someday...
bundle = (_bundler, changed) ->
  compileStream = _bundler
    .bundle()
    .on('error', gutil.log.bind(gutil, gutil.colors.red('Browserify Error\n')))
    .pipe(source('main.js'))
    .pipe(gulp.dest('dist/js'))

  if changed
    lintStream = gulp.src(changed)
      .pipe(coffeelint(coffeelintOpts))
      .pipe(coffeelint.reporter())

    return merge(lintStream, compileStream)

  return compileStream


gulp.task 'browserify', ->
  bundle(bundler)


gulp.task 'prelint', ->
  gulp.src('./src/**/*.coffee')
    .pipe(coffeelint(coffeelintOpts))
    .pipe(coffeelint.reporter())


gulp.task 'less', ->
  gulp.src 'less/main.less'
  .pipe plumber()
  .pipe less()
  .pipe gulp.dest 'dist/css'


gulp.task 'less-watch', ['less'], ->
  watch 'less/**/*.less', ->
    gulp.start 'less'
  , verbose: true


gulp.task 'browserify-watch', ['prelint'], ->
  watcher = watchify(bundler)
  watcher.on 'update', (changed) -> bundle(watcher, changed)
  watcher.on 'log', gutil.log
  bundle(watcher)
  gulp.start 'less-watch'
