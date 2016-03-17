fs = require 'fs'

module.exports = (gulp, plugins, config) ->

    gulp.task 'commit-changes', ->
        gulp.src('.')
            .pipe(plugins.git.add())
            .pipe(plugins.git.commit('[Prerelease] Bumped version number'))

    gulp.task 'push-changes', (callback) ->
        plugins.git.push('origin', 'master', callback)

    gulp.task 'create-new-tag', (callback) ->
        version = JSON.parse(fs.readFileSync('./package.json', 'utf8')).version
        plugins.git.tag version, 'Created Tag for version: ' + version, (error) ->
            return callback(error) if error
            plugins.git.push('origin', 'master', {args: '--tags'}, callback)
