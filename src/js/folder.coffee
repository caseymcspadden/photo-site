$ = require 'jquery'
require 'foundation'
_ = require 'underscore'
Backbone = require 'backbone'
Session = require('../../require/session')
LoginView = require('../../require/login-view')
SessionMenuView = require('../../require/session-menu-view')
Galleries = require('../../require/galleries')
FolderView = require('../../require/folder-view')

session = new Session
loginView = new LoginView {model: session}
sessionMenuView = new SessionMenuView({el: '.session-menu', model: session})

$('body').append loginView.render().el

galleries = new Galleries
folderView = new FolderView {collection: galleries, el: '.folder-view'}

folderView.render()

session.fetch()
galleries.fetch {reset: true}

$(document).foundation()
#new Foundation.DropdownMenu($('.dropdown'))
