$ = require 'jquery'
require 'foundation'
_ = require 'underscore'
Backbone = require 'backbone'
Session = require('../../require/session')
LoginView = require('../../require/login-view')
SessionMenuView = require('../../require/session-menu-view')
CartItems = require('../../require/cartitems')
CartSummaryView = require('../../require/cart-summary-view')
CheckoutView =  require('../../require/checkout-view')

#Galleries = require('../../require/galleries')
#PortfolioView = require('../../require/portfolio-view')

session = new Session
loginView = new LoginView {model: session}
sessionMenuView = new SessionMenuView({el: '.session-menu', model: session})
cartItems = new CartItems
cartSummaryView = new CartSummaryView {el: '.cart-summary-view', collection: cartItems}
checkoutView = new CheckoutView {el: '.checkout-view', collection: cartItems}

$('body').append loginView.render().el

$ ->
	session.fetch()
	cartItems.fetch {reset: true}

$(document).foundation()
