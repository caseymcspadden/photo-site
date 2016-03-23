$ = require 'jquery'
foundation = require 'foundation'
_ = require('underscore')
dropzone = require('dropzone')
Backbone = require('backbone')
Admin = require('../../require/admin')
AdminFoldersView = require('../../require/admin-folders-view')
AdminMainView = require('../../require/admin-main-view')

admin = new Admin()

adminFoldersView = new AdminFoldersView({el: '#adminFoldersView', model: admin})
adminMainView = new AdminMainView({el: '#adminMainView', model: admin})

adminFoldersView.render();
adminMainView.render();

admin.fetchAll()

$(document).foundation()
