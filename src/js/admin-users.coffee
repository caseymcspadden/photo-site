$ = require 'jquery'
require 'foundation'
UsersCollection = require('../../require/users')
AdminUsersView = require('../../require/admin-users-view')

usersCollection = new UsersCollection

adminUsersView = new AdminUsersView {el: '.admin-users-view', collection: usersCollection}

adminUsersView.render()

usersCollection.fetch {reset: true}

$ ->
	$(document).foundation()
