runSequence = require 'run-sequence'

module.exports = (gulp, plugins, config) ->

    gulp.task 'bump-version-patch', ->
        gulp.src('./package.json')
            .pipe(plugins.bump(type: 'patch').on('error', plugins.util.log))
            .pipe(gulp.dest('./'))

    gulp.task 'bump-version-feature', ->
        console.log 'bump-version-feature'
        gulp.src('./package.json')
            .pipe(plugins.bump(type: 'minor').on('error', plugins.util.log))
            .pipe(gulp.dest('./'))

    gulp.task 'bump-version-release', ->
        console.log 'bump-version-release'
        gulp.src('./package.json')
            .pipe(plugins.bump(type: 'major').on('error', plugins.util.log))
            .pipe(gulp.dest('./'))

    gulp.task 'patch', -> increment('patch')
    gulp.task 'feature', -> increment('feature')
    gulp.task 'release', -> increment('release')

    increment = (importance) ->
        runSequence(
            'bump-version-' + importance,
            'changelog',
            'commit-changes',
            'push-changes',
            'create-new-tag',
        )
