coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
gulp = require 'gulp'
notify = require 'gulp-notify'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
plugins = require('gulp-load-plugins')()
pkg = require './package.json'
config = {}

require('./tasks/git')(gulp, plugins, config)
require('./tasks/changelog')(gulp, plugins, config)
require('./tasks/bump')(gulp, plugins, config)

handleErrors = ->
    args = Array.prototype.slice.call(arguments)
    notify.onError(title: 'Compile Error', message: '<%= error.message %>').apply(this, args)
    this.emit 'end'

gulp.task 'default', ['build']

gulp.task 'coffee', ->
    gulp.src './src/index.coffee'
        .pipe coffeelint(pkg.coffeelintConfig)
        .pipe coffeelint.reporter()
        .pipe coffee().on('error', handleErrors)
        .pipe gulp.dest('lib')

gulp.task 'build', ['coffee'], ->
    gulp.src './lib/jsonp.js'
        .pipe uglify()
        .pipe rename(extname: '.min.js')
        .pipe gulp.dest('lib')
