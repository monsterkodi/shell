
module.exports = (grunt) ->

    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        pepper:
            options:
                template: '::'
                pepper: ['log']
                paprika: ['dbg']
            task:
                files:
                    'pwm': [ 'pwm.coffee' ]

        salt:
            options:
                dryrun:  false
                verbose: true
                refresh: false
            coffee:
                files:
                    'asciiText':   ['**/*.coffee']

        stylus:
            options:
                compress: false
            compile:
                files:
                    'pwm.css': ['pwm.styl']
                    'style/bright.css': ['style/bright-style.styl']
                    'style/dark.css': ['style/dark-style.styl']

        bower_concat:
            all:
                dest: 'js/lib/bower.js'
                bowerOptions:
                    relative: false
                exclude: ['octicons', 'font-awesome']

        watch:
          sources:
            files: ['./*.coffee', './coffee/**/*.coffee', '*.styl', '*.html']
            tasks: ['build']

        coffee:
            options:
                bare: true
            pwm:
                expand: true,
                flatten: true,
                cwd: '.',
                src: ['.pepper/pwm.coffee'],
                dest: 'js',
                ext: '.js'
            coffee:
                expand: true,
                flatten: true,
                cwd: '.',
                src: ['coffee/*.coffee'],
                dest: 'js/coffee',
                ext: '.js'
            knix:
                expand: true,
                flatten: true,
                cwd: '.',
                src: ['coffee/knix/*.coffee'],
                dest: 'js/coffee/knix',
                ext: '.js'
            tools:
                expand: true,
                flatten: true,
                cwd: '.',
                src: ['coffee/tools/*.coffee'],
                dest: 'js/coffee/tools',
                ext: '.js'

        bumpup:
            file: 'package.json'

        shell:
            kill:
                command: "killall Electron"
            clean: 
                command: "rm -rf pwm.app"
            build: 
                command: "node_modules/electron-packager/cli.js . pwm --platform=darwin --arch=x64 --version=0.26.0 --ignore=node_modules/electron --icon=Icon.icns"
            test: 
                command: "electron ."
            start: 
                command: "killall Electron || sleep 1 && open pwm.app"
            publish:
                command: 'npm publish'
            npmpage:
                command: 'open https://www.npmjs.com/package/pwm'
    ###
    npm install --save-dev grunt-contrib-watch
    npm install --save-dev grunt-contrib-coffee
    npm install --save-dev grunt-contrib-stylus
    npm install --save-dev grunt-bower-concat
    npm install --save-dev grunt-bumpup
    npm install --save-dev grunt-pepper
    npm install --save-dev grunt-shell
    ###

    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-stylus'
    grunt.loadNpmTasks 'grunt-bower-concat'
    grunt.loadNpmTasks 'grunt-bumpup'
    grunt.loadNpmTasks 'grunt-pepper'
    grunt.loadNpmTasks 'grunt-shell'

    grunt.registerTask 'build',     [ 'bumpup', 'stylus', 'salt', 'pepper', 'bower_concat', 'coffee', 'shell:clean', 'shell:build', 'shell:start' ]
    grunt.registerTask 'test',      [ 'bumpup', 'stylus', 'salt', 'pepper', 'bower_concat', 'coffee', 'shell:clean', 'shell:build', 'shell:test' ]
    grunt.registerTask 'default',   [ 'test' ]
    #grunt.registerTask 'publish',   [ 'bumpup', 'shell:publish', 'shell:npmpage' ]
