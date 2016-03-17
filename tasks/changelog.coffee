conventionalChangelog = require 'gulp-conventional-changelog'

module.exports = (gulp, plugins, config) ->
    gulp.task 'changelog', ->
        gulp.src('CHANGELOG.md', { buffer: false })
            .pipe(conventionalChangelog(preset: 'angular'))
            .pipe(gulp.dest('./'))
