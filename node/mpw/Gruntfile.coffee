
module.exports = (grunt) ->

    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        pepper:
            options:
                template: '::'
            task:
                files:
                    'mpw': [ 'mpw.coffee' ]

        salt:
            options:
                dryrun:  false
                verbose: true
                refresh: false
            coffee:
                files:
                    'asciiHeader': ['**/*.coffee']
                    'asciiText':   ['**/*.coffee']

        watch:
          sources:
            files: ['*.coffee', 'coffee/**.coffee']
            tasks: ['build']

        coffee:
            options:
                bare: true
            ls:
                expand: true,
                flatten: true,
                cwd: '.',
                src: ['.pepper/mpw.coffee'],
                dest: 'js',
                ext: '.js'
            coffee:
                expand: true,
                flatten: true,
                cwd: '.',
                src: ['coffee/*.coffee'],
                dest: 'js/coffee',
                ext: '.js'

        bumpup:
            file: 'package.json'

        shell:
            publish:
                command: 'npm publish'
            npmpage:
                command: 'open https://www.npmjs.com/package/mpw'

    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-bumpup'
    grunt.loadNpmTasks 'grunt-pepper'
    grunt.loadNpmTasks 'grunt-shell'

    grunt.registerTask 'build',     [ 'salt', 'pepper', 'coffee' ]
    grunt.registerTask 'default',   [ 'build' ]
    #grunt.registerTask 'publish',   [ 'bumpup', 'shell:publish', 'shell:npmpage' ]

# npm install --save-dev grunt
# npm install --save-dev grunt-contrib-watch
# npm install --save-dev grunt-contrib-coffee
# npm install --save-dev grunt-bumpup
# npm install --save-dev grunt-pepper
# npm install --save-dev grunt-shell
