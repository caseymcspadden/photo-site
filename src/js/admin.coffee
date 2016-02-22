$ = require 'jquery'
foundation = require 'foundation'
_ = require('underscore')
dropzone = require('dropzone')
Backbone = require('backbone')
PhotoApp = require('../../require/photoapp')
FoldersView = require('../../require/folders-view')
GalleryView = require('../../require/gallery-view')

$(document).foundation()

photoApp = new PhotoApp({}, {photos: photos, folders: folders})

foldersview = new FoldersView({el: '#foldersView', app: photoApp})
galleryview = new GalleryView({el: '#galleryView', app: photoApp})

foldersview.render();

$(".filedrop").dropzone
  url: "services/upload"
  uploadMultiple: true
  addRemoveLinks: false
  acceptedFiles: 'image/*'
  maxFileSize: 50

$('#uploadModal .close-button').click (e) ->
  console.log e
  $('.filedrop').html('')


