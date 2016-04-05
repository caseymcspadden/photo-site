$ = require 'jquery'
foundation = require 'foundation'
ViewModel = require('../../require/viewmodel')
Session = require('../../require/session')
Settings = require('../../require/settings')
AdminSettingsView = require('../../require/admin-settings-view')
AdminFoldersView = require('../../require/admin-folders-view')
AdminMainView = require('../../require/admin-main-view')

viewModel = new ViewModel {allowDragDrop: true}
session = new Session()
settings = new Settings null, {session: session}

adminSettinsView = new AdminSettingsView {model: viewModel, session: session}

adminFoldersView = new AdminFoldersView({el: '#adminFoldersView', model: viewModel})
adminMainView = new AdminMainView({el: '#adminMainView', model: viewModel})

adminFoldersView.render()
adminMainView.render()

session.fetch()
viewModel.fetchAll()

$(document).foundation()
