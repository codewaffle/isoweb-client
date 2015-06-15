gulp = require 'gulp'
gutil = require 'gulp-util'

gulp.task 'watch', ['browserify-watch', 'copy_public-watch'], ->
  gutil.log 'Initial build gathered, and now my watch begins...'