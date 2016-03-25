$ = require 'jquery'
foundation = require 'foundation'
UsersCollection = require('../../require/users')
UsersView = require('../../require/admin-users-view')

usersCollection = new UsersCollection null, {urlBase: '/photo-site/build'}

usersView = new UsersView({el: '#adminUsersView', collection: usersCollection})

usersCollection.fetch {reset: true}

$(document).foundation()
