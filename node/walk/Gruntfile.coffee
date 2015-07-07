
module.exports = (grunt) ->

    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        pepper:
            options:
                template: '::'
                pepper:  ['log']
                paprika: ['dbg']
                join:    false
                quiet:   true
            turtle:
                files:
                    'turtle': [ 'coffee/**/*.coffee' ]
        salt:
            options:
                dryrun:  false
                verbose: true
                refresh: false
            coffeelarge:
                options:
                    textMarker  : '#!!'
                files:
                    'asciiText': [ 'coffee/**/*.coffee' ]
            coffeesmall:
                options:
                    textMarker  : '#!'
                    textPrefix  : null
                    textFill    : '# '
                    textPostfix : null
                files:
                    'asciiText': [ 'coffee/**/*.coffee' ]
            style: 
                options:
                    verbose     : false
                    textMarker  : '//!'
                    textPrefix  : '/*'
                    textFill    : '*  '
                    textPostfix : '*/'
                files:
                    'asciiText' : ['style/*.styl']

        stylus:
            options:
                compress: false
            compile:
                files:
                    'style/style.css': ['style/style.styl']

        bower_concat:
            all:
                dest: 'js/lib/bower.js'
                bowerOptions:
                    relative: false
                exclude: ['font-awesome']

        watch:
          sources:
            files: ['coffee/**/*.coffee', '**/*.styl', '*.html']
            tasks: ['test']

        coffee:
            options:
                bare: true
            coffee:
                expand:  true,
                flatten: true,
                cwd:     '.',
                src:     ['.pepper/coffee/*.coffee'],
                dest:    'js',
                ext:     '.js'

        bumpup:
            file: 'package.json'
            
        clean: ['style/*.css', 'js', '.pepper']
            
        shell:
            options:
                execOptions: 
                    maxBuffer: Infinity
            test:
                command: 'node js/index.js'
    ###
    npm install --save-dev grunt-contrib-watch
    npm install --save-dev grunt-contrib-coffee
    npm install --save-dev grunt-contrib-stylus
    npm install --save-dev grunt-contrib-clean
    npm install --save-dev grunt-bower-concat
    npm install --save-dev grunt-bumpup
    npm install --save-dev grunt-pepper
    npm install --save-dev grunt-shell
    ###

    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-stylus'
    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-bower-concat'
    grunt.loadNpmTasks 'grunt-github-release-asset'
    grunt.loadNpmTasks 'grunt-bumpup'
    grunt.loadNpmTasks 'grunt-pepper'
    grunt.loadNpmTasks 'grunt-shell'

    grunt.registerTask 'build',     [ 'clean', 'bumpup', 'stylus', 'salt', 'pepper', 'bower_concat', 'coffee' ]
    grunt.registerTask 'test',      [ 'build', 'shell:test' ]
    grunt.registerTask 'default',   [ 'test' ]
