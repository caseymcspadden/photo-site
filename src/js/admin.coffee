$ = require 'jquery'
foundation = require 'foundation'
_ = require('underscore')
dropzone = require('dropzone')
Backbone = require('backbone')
Admin = require('../../require/admin')
AdminFoldersView = require('../../require/admin-folders-view')
AdminMainView = require('../../require/admin-main-view')
AdminPhotosView = require('../../require/admin-photos-view')

$(document).foundation()

admin = new Admin({}, {folders: folders})

adminFoldersView = new AdminFoldersView({el: '#adminFoldersView', model: admin})
adminMainView = new AdminMainView({el: '#adminMainView', model: admin})
adminPhotosView = new AdminPhotosView({el: '#adminPhotosView', model: admin})

adminFoldersView.render();
adminMainView.render();
adminPhotosView.render();

admin.photos.fetch {reset:true}


$(".filedrop").dropzone
  url: "services/upload"
  uploadMultiple: true
  addRemoveLinks: false
  acceptedFiles: 'image/*'
  maxFileSize: 50

$('#uploadModal .close-button').click (e) ->
  console.log e
  $('.filedrop').html('')


