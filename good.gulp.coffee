bump = require 'gulp-bump'
coffee = require 'gulp-coffee'
coffeelint = require 'gulp-coffeelint'
conventionalChangelog = require 'gulp-conventional-changelog'
git = require 'gulp-git'
gulp = require 'gulp'
gutil = require 'gulp-util'
notify = require 'gulp-notify'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
runSequence = require 'run-sequence'
fs = require 'fs'
pkg = require './package.json'

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

gulp.task 'changelog', ->
    gulp.src('CHANGELOG.md', { buffer: false })
        .pipe(conventionalChangelog(preset: 'angular'))
        .pipe(gulp.dest('./'))

gulp.task 'bump-version-patch', ->
    gulp.src('./package.json')
        .pipe(bump(type: 'patch').on('error', gutil.log))
        .pipe(gulp.dest('./'))

gulp.task 'bump-version-feature', ->
    console.log 'bump-version-feature'
    gulp.src('./package.json')
        .pipe(bump(type: 'minor').on('error', gutil.log))
        .pipe(gulp.dest('./'))

gulp.task 'bump-version-release', ->
    console.log 'bump-version-release'
    gulp.src('./package.json')
        .pipe(bump(type: 'major').on('error', gutil.log))
        .pipe(gulp.dest('./'))

gulp.task 'commit-changes', ->
    gulp.src('.')
        .pipe(git.add())
        .pipe(git.commit('[Prerelease] Bumped version number'))

gulp.task 'push-changes', (cb) ->
    git.push('origin', 'master', cb)

gulp.task 'create-new-tag', (cb) ->
    getPackageVersion = ->
        # We parse the json file instead of using require because require caches
        # multiple calls so the version number won't be updated
        return JSON.parse(fs.readFileSync('./package.json', 'utf8')).version
    version = getPackageVersion()
    git.tag version, 'Created Tag for version: ' + version, (error) ->
        return cb(error) if error
        git.push('origin', 'master', {args: '--tags'}, cb)

#gulp.task 'release', (importance, callback) ->
increment = (importance, callback) ->
    cb = (error) ->
        console.log(error.message) if error
        callback(error)
    console.log importance
    runSequence(
        'bump-version-' + importance,
        'changelog',
        'commit-changes',
        'push-changes',
        'create-new-tag',
        #cb
    )

gulp.task 'patch', -> increment('patch')
gulp.task 'feature', -> increment('feature')
gulp.task 'release', -> increment('release')
