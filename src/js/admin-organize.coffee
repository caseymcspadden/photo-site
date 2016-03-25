$ = require 'jquery'
foundation = require 'foundation'
ViewModel = require('../../require/viewmodel')
AdminFoldersView = require('../../require/admin-folders-view')
AdminMainView = require('../../require/admin-main-view')

viewModel = new ViewModel {allowDragDrop: true}, {urlBase: '/photo-site/build'}

adminFoldersView = new AdminFoldersView({el: '#adminFoldersView', model: viewModel})
adminMainView = new AdminMainView({el: '#adminMainView', model: viewModel})

adminFoldersView.render();
adminMainView.render();

viewModel.fetchAll();

$(document).foundation()
