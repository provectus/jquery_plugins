module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    coffee: {
      glob_to_multiple: {
      	expand: true,
      	flatten: true,
      	cwd: './',
      	src: ['*.coffee', '../constants.jquery.coffee', '../customval.jquery.coffee', '../mutations.jquery.coffee'],
      	dest: 'js/',
      	ext: '.js'
      }
    },
    concat: {
      options: {
        separator: ';'
      },
      dist: {
        src: [
          'js/constants.js',
          'js/customval.js',
          'js/mutations.js',
          'js/select.js',
        ],
        dest: 'js/joined.js'
      }
    },
   uglify: {
     options: {
       banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
     },
     dist: {
      files: {
        'selects.jquery.min.js': ['js/joined.js']
      }
     }
   },
   compass: {
     dist: {
       options: {
         sassDir: '.',
         cssDir: '.'
       }
     }
   },
   cssmin: {
     dist: {
       files: {
         'selects.jquery.min.css': ['selects.jquery.css']
       }
     }
   }
  });

  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-compass');
  grunt.loadNpmTasks('grunt-contrib-cssmin');

  grunt.registerTask('default', ['coffee', 'concat', 'uglify', 'compass', 'cssmin']);

};
