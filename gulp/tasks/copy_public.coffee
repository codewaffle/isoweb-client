gulp = require 'gulp'
watch = require 'gulp-watch'
batch = require 'gulp-batch'

gulp.task 'copy_public', ->
  gulp.src('./public_html/**/*')
    .pipe(gulp.dest('./dist'))

gulp.task 'copy_public-watch', ['copy_public'], ->
  watch './public_html/**/*', batch (evt, done) ->
      evt.pipe(gulp.dest('./dist'))
      done()