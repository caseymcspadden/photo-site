$ = require 'jquery'
require 'foundation'
_ = require 'underscore'
Backbone = require 'backbone'
Session = require('../../require/session')
LoginView = require('../../require/login-view')
SessionMenuView = require('../../require/session-menu-view')
Galleries = require('../../require/galleries')
PortfolioView = require('../../require/portfolio-view')

session = new Session
loginView = new LoginView {model: session}
sessionMenuView = new SessionMenuView({el: '.session-menu', model: session})

galleries = new Galleries
portfolioView = new PortfolioView {collection: galleries, el: '.portfolio-view'}

$('body').append loginView.render().el

session.fetch()
galleries.fetch {reset: true}

$(document).foundation()
#new Foundation.DropdownMenu($('.dropdown'))
