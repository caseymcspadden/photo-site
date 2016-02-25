$ = require 'jquery'
foundation = require 'foundation'
_ = require('underscore')
dropzone = require('dropzone')
Backbone = require('backbone')
Admin = require('../../require/admin')
AdminFoldersView = require('../../require/admin-folders-view')
AdminMainView = require('../../require/admin-main-view')

$(document).foundation()

admin = new Admin({}, {folders: folders})

adminFoldersView = new AdminFoldersView({el: '#adminFoldersView', admin: admin})
adminMainView = new AdminMainView({el: '#adminMainView', admin: admin})

adminFoldersView.render();
adminMainView.render();

$(".filedrop").dropzone
  url: "services/upload"
  uploadMultiple: true
  addRemoveLinks: false
  acceptedFiles: 'image/*'
  maxFileSize: 50

$('#uploadModal .close-button').click (e) ->
  console.log e
  $('.filedrop').html('')


