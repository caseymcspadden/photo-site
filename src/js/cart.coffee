$ = require 'jquery'
require 'foundation'
_ = require 'underscore'
Backbone = require 'backbone'
Session = require('../../require/session')
LoginView = require('../../require/login-view')
SessionMenuView = require('../../require/session-menu-view')
CartSummaryView = require('../../require/cart-summary-view')
CartItems = require('../../require/cartitems')
CartView =  require('../../require/cart-view')

#Galleries = require('../../require/galleries')
#PortfolioView = require('../../require/portfolio-view')

session = new Session
loginView = new LoginView {model: session}
sessionMenuView = new SessionMenuView({el: '.session-menu', model: session})
cartItems = new CartItems
cartSummaryView = new CartSummaryView {el: '.cart-summary-view', collection: cartItems}
cartView = new CartView {el: '.cart-view', collection: cartItems}

#galleries = new Galleries
#portfolioView = new PortfolioView {collection: galleries, el: '.portfolio-view'}

$('body').append loginView.render().el

#galleryMainView = new GalleryMainView {model: new Gallery, el: '.gallery-main-view', cart: cartItems}
#galleryMainView.render()

$ ->
	session.fetch()
	cartItems.fetch {reset: true}

$(document).foundation()
