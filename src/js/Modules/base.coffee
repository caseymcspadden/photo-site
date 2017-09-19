$ = require 'jquery'
require 'foundation'
Session = require './session'
LoginView = require './login-view'
SessionMenuView = require './session-menu-view'
CartSummaryView = require './cart-summary-view'
CartItems = require './cartitems'

module.exports = {
	initialize: (sessionMenuElement, cartSummaryElement) ->
		this.session = new Session
		this.loginView = new LoginView {model: this.session}
		this.sessionMenuView = new SessionMenuView({el: sessionMenuElement, model: this.session})
		this.cartItems = new CartItems
		this.cartSummaryView = new CartSummaryView {el: cartSummaryElement, collection: this.cartItems}
		$('body').append this.loginView.render().el

	onLoad: ->
		this.session.fetch()
		this.cartItems.fetch {reset: true}
	}