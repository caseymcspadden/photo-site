$ = require 'jquery'
require 'foundation'
_ = require 'underscore'
Backbone = require 'backbone'
Session = require('../../require/session')
LoginView = require('../../require/login-view')
SessionMenuView = require('../../require/session-menu-view')
Gallery = require('../../require/gallery')
GalleryMainView = require('../../require/gallery-main-view')
CartSummaryView = require('../../require/cart-summary-view')

#Galleries = require('../../require/galleries')
#PortfolioView = require('../../require/portfolio-view')

session = new Session
loginView = new LoginView {model: session}
sessionMenuView = new SessionMenuView({el: '.session-menu', model: session})
cartSummaryView = new CartSummaryView {el: '.cart-summary-view'}

#galleries = new Galleries
#portfolioView = new PortfolioView {collection: galleries, el: '.portfolio-view'}

$('body').append loginView.render().el

galleryMainView = new GalleryMainView {model: new Gallery, el: '.gallery-main-view'}
galleryMainView.render()

$ ->
	session.fetch()
#galleries.fetch {reset: true}

$(document).foundation()
#new Foundation.DropdownMenu($('.dropdown'))
