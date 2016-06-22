$ = require 'jquery'
require 'foundation'
_ = require 'underscore'
Backbone = require 'backbone'
Session = require('../../require/session')
LoginView = require('../../require/login-view')
SessionMenuView = require('../../require/session-menu-view')
CartItems = require('../../require/cartitems')
CartSummaryView = require('../../require/cart-summary-view')
Order = require('../../require/order')
OrderView = require('../../require/order-view')

session = new Session
loginView = new LoginView {model: session}
sessionMenuView = new SessionMenuView({el: '.session-menu', model: session})
cartItems = new CartItems
cartSummaryView = new CartSummaryView {el: '.cart-summary-view', collection: cartItems}

$('body').append loginView.render().el

orderid = document.location.pathname.replace(/^.*\/orders\//,'')

order = new Order {orderid : orderid}
orderView = new OrderView {model: order, el: '.order-view'}

$ ->
	session.fetch()
	cartItems.fetch {reset: true}
	order.retrieve()

$(document).foundation()
