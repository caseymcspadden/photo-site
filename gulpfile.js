var browserSync  = require('browser-sync');
var browserify   = require('browserify');
var source       = require('vinyl-source-stream');
var buffer       = require('vinyl-buffer');
var coffeeify	   = require('coffeeify');
var gulp         = require('gulp');
var gutil        = require('gulp-util');
var gulpSequence = require('gulp-sequence');
var processhtml  = require('gulp-htmlmin');
var sass         = require('gulp-sass');
var watch        = require('gulp-watch');
var minifycss    = require('gulp-cssnano');
var uglify       = require('gulp-uglify');
var gcoffee      = require('gulp-coffee');
var streamify    = require('gulp-streamify');
var sourcemaps   = require('gulp-sourcemaps');
var concat       = require('gulp-concat');
var rename       = require('gulp-rename');
var jst          = require('gulp-jst2');
var insert       = require('gulp-insert');
var glob 		     = require("glob");
var mkdirp       = require("mkdirp");
var del          = require('del');
var es           = require("event-stream");

var prod         = gutil.env.prod;

var onError = function(err) {
  console.log(err.message);
  this.emit('end');
};

var done = function(err) {
  if (err) {
    console.log(err.message);
    this.emit('end');
  }
  else 
    console.log("Done");
};

gulp.task('clean:scripts', function() {
  return del(['build/js/**/*.js','require']);
});

gulp.task('clean', function() {
  return del(['build']);
});

gulp.task('fileroot', function() {
  mkdirp('fileroot/photos', '0777', function (err, made) {
    if (made) {
      console.log("Made " + made);
      gulp.src('src/app.cfg')
      .pipe(gulp.dest('fileroot'));
    }
  });
});

gulp.task('jst', function() {

  return gulp.src(['src/js/Templates/*.html'])

    // Minify the HTML prior to converting to JST
    .pipe(processhtml({ collapseWhitespace: false, removeComments: true, removeCommentsFromCDATA: true }))

    // Convert to JST and assign to app.templates which we'll define once all files are concatenated in
    .pipe(jst({ prepend: 'templates["%s"] = ' }))

    // Concatenate all files together and insert a comma before each newLine
    .pipe(concat('jst.js', { newLine: ',\n' }))

    // Insert the start of an IIFE and variable declarations at the beginning of the file
    .pipe(insert.prepend('(function() {\n_=require("underscore");\nvar templates = {};\n\n'))

    // Insert the end of an IIFE and return the object at the end of the file (also the last function from the jst call will not end with a semicolon, so add one here)
    .pipe(insert.append('\nmodule.exports=templates;\n}).call(this);'))

    // Uglify the JS
    .pipe(uglify())

    .pipe(gulp.dest('require'));
});

// scripts
gulp.task('scripts', ['clean:scripts', 'jst'],  function() {

  gulp.src('src/js/Models/*.coffee')
    .pipe(gcoffee())
    .pipe(gulp.dest('require'));

  gulp.src('src/js/Collections/*.coffee')
    .pipe(gcoffee())
    .pipe(gulp.dest('require'));

  gulp.src('src/js/Views/*.coffee')
    .pipe(gcoffee())
    .pipe(gulp.dest('require'));
 
  glob('./src/js/*.*', function(err, files) {
    if(err) done(err);

    var tasks = files.map(function(entry) {
      return browserify({ 
            entries: [entry],
            transform: ['coffeeify'],
    		    extensions: ['.coffee']
       	  })
          .bundle()
          .pipe(source(entry))
          .pipe(buffer())
          .pipe(rename({
              dirname: '.',
              extname: '.bundle.js'
          }))
          .pipe(prod ? sourcemaps.init() : gutil.noop())
          .pipe(prod ? streamify(uglify()) : gutil.noop())
          .pipe(prod ? sourcemaps.write('.') : gutil.noop())
          .pipe(gulp.dest('build/js'))
          .pipe(browserSync.stream());
      });
    return es.merge(tasks).on('end', done);
  });
});

// vendor
gulp.task('vendor', function() {
  return gulp.src('./vendor/**/*.*')
    .pipe(gulp.dest('build/vendor'))
    .pipe(browserSync.stream());
});

// root
gulp.task('root', ['fileroot'], function() {
  mkdirp('build/photos', '0777', function (err) {
    if (err)
      console.log(err);
  });
  gulp.src(['src/images/**/*.*'])
    .pipe(gulp.dest('build/images'));
 
  return gulp.src(['src/.htaccess', './src/*.*'])
    .pipe(gulp.dest('build'))
    .pipe(browserSync.stream());
});

// html
gulp.task('html', function() {
  return gulp.src('./src/templates/**/*.html')
    .pipe(processhtml())
    .pipe(gulp.dest('build/templates'))
    .pipe(browserSync.stream());
});

// sass
gulp.task('sass', function() {
  return gulp.src('./src/scss/**/*.scss')
    .pipe(sass({
      includePaths: require('node-bourbon').includePaths
    }))
    .on('error', onError)
    .pipe(prod ? minifycss() : gutil.noop())
    .pipe(gulp.dest('./build/stylesheets'))
    .pipe(browserSync.stream());
});

// browser sync server for live reload
gulp.task('serve', function() {
  browserSync.init({
    proxy: 'localhost:8888/photo-site/build'
    //server: {
      //baseDir: './build'
    //}
  });

  gulp.watch('./src/*.*', ['root']);
  gulp.watch('./src/templates/**/*.*', ['html']);
  gulp.watch('./src/scss/**/*.scss', ['sass']);
  gulp.watch('./src/js/**/*.*', ['scripts']);
});

// use gulp-sequence to finish building html, sass and js before first page load
gulp.task('build', gulpSequence(['vendor', 'root', 'html', 'sass', 'scripts']));
gulp.task('default', gulpSequence(['build'], 'serve'));