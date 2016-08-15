$ = require 'jquery'
require 'foundation'
Base = require '../../require/base'
CheckoutView =  require('../../require/checkout-view')

Base.initialize '.session-menu', '.cart-summary-view'

checkoutView = new CheckoutView {el: '.checkout-view', collection: Base.cartItems}
checkoutView.render()

$ ->
	Base.onLoad()

$(document).foundation()
