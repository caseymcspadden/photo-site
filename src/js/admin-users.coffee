$ = require 'jquery'
require 'foundation'
UsersCollection = require('../../require/users')
AdminUsersView = require('../../require/admin-users-view')
Session = require('../../require/session')
Settings = require('../../require/settings')
AdminSettingsView = require('../../require/admin-settings-view')

usersCollection = new UsersCollection

adminUsersView = new AdminUsersView {el: '.admin-users-view', collection: usersCollection}

session = new Session()
settings = new Settings null, {session: session}
adminSettingsView = new AdminSettingsView {el: '#admin-editSettings', model:settings}

adminUsersView.render()
adminSettingsView.render()

session.fetch()
usersCollection.fetch {reset: true}

$ ->
	$(document).foundation()
