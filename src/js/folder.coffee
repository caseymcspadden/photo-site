$ = require 'jquery'
require 'foundation'
_ = require 'underscore'
Backbone = require 'backbone'
Session = require('../../require/session')
LoginView = require('../../require/login-view')
SessionMenuView = require('../../require/session-menu-view')
Folder = require('../../require/folder')
FolderView = require('../../require/folder-view')
config = require('../../require/config')

session = new Session
loginView = new LoginView {model: session}
sessionMenuView = new SessionMenuView({el: '.session-menu', model: session})

$('body').append loginView.render().el

folderView = new FolderView {model: new Folder, el: '.folder-view'}

folderView.render()

session.fetch()

$(document).foundation()
#new Foundation.DropdownMenu($('.dropdown'))
