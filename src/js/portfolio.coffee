$ = require 'jquery'
require 'foundation'
_ = require 'underscore'
Backbone = require 'backbone'
Session = require('../../require/session')
LoginView = require('../../require/login-view')
SessionMenuView = require('../../require/session-menu-view')
Galleries = require('../../require/containers')
FolderView = require('../../require/folder-view')

session = new Session
loginView = new LoginView {model: session}
sessionMenuView = new SessionMenuView({el: '.session-menu', model: session})

galleries = new Galleries
folderView = new FolderView {collection: galleries, el: '.folder-view'}

$('body').append loginView.render().el

$ ->
	session.fetch()
	galleries.fetch {reset: true}

$(document).foundation()
#new Foundation.DropdownMenu($('.dropdown'))
