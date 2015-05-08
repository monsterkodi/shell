# npm install --save-dev grunt
# npm install --save-dev grunt-contrib-watch
# npm install --save-dev grunt-contrib-coffee
# npm install --save-dev grunt-pepper
# npm install --save-dev grunt-shell

module.exports = (grunt) ->

    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

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
                src: ['*.coffee'],
                dest: 'js',
                ext: '.js'
            coffee:
                expand: true,
                flatten: true,
                cwd: '.',
                src: ['coffee/*.coffee'],
                dest: 'js/coffee',
                ext: '.js'

        # shell:
        #     program:
        #         command: 'export PATH=$PATH:/usr/local/CrossPack-AVR/bin && echo $PATH && make program'
        #     clean:
        #         command: 'make clean'

    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-pepper'
    grunt.loadNpmTasks 'grunt-shell'

    grunt.registerTask 'build',     [ 'salt', 'coffee' ]
    grunt.registerTask 'default',   [ 'build' ]
