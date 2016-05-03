$ = require 'jquery'
require 'foundation'
_ = require 'underscore'
Backbone = require 'backbone'
Session = require('../../require/session')
LoginView = require('../../require/login-view')
SessionMenuView = require('../../require/session-menu-view')
CartSummaryView = require('../../require/cart-summary-view')
CartItems = require('../../require/cartitems')

session = new Session
loginView = new LoginView {model: session}
sessionMenuView = new SessionMenuView {el: '.session-menu', model: session}
cartSummaryView = new CartSummaryView {el: '.cart-summary-view', collection: cartItems}

$('body').append loginView.render().el

$ ->
	session.fetch()
	cartItems.fetch {reset: true}

$(document).foundation()