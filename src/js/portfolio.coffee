$ = require 'jquery'
require 'foundation'
_ = require 'underscore'
Backbone = require 'backbone'
Session = require('../../require/session')
LoginView = require('../../require/login-view')
SessionMenuView = require('../../require/session-menu-view')

session = new Session
loginView = new LoginView {model: session}
sessionMenuView = new SessionMenuView({el: '.session-menu', model: session})

session.fetch()

$('body').append loginView.render().el

$(document).foundation()
#new Foundation.DropdownMenu($('.dropdown'))
