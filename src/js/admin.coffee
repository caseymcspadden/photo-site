$ = require 'jquery'
foundation = require 'foundation'
_ = require('underscore')
dropzone = require('dropzone')
Backbone = require('backbone')
Admin = require('../../require/admin')
AdminFoldersView = require('../../require/admin-folders-view')
AdminMainView = require('../../require/admin-main-view')
AdminPhotosView = require('../../require/admin-photos-view')
AdminDropzoneView = require('../../require/admin-dropzone-view')

$(document).foundation()

admin = new Admin({}, {folders: folders})

adminFoldersView = new AdminFoldersView({el: '#adminFoldersView', model: admin})
adminMainView = new AdminMainView({el: '#adminMainView', model: admin})
adminPhotosView = new AdminPhotosView({el: '#adminPhotosView', model: admin})
adminDropzoneView = new  AdminDropzoneView {el: '#uploadModal', model: admin}

adminFoldersView.render();
adminMainView.render();
adminPhotosView.render();
adminDropzoneView.render();

admin.photos.fetch {reset:true}
