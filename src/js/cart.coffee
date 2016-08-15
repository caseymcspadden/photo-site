$ = require 'jquery'
require 'foundation'
CartView =  require('../../require/cart-view')
Base = require '../../require/base'

Base.initialize '.session-menu', '.cart-summary-view'

cartView = new CartView {el: '.cart-view', collection: Base.cartItems}

cartView.render()

$ ->
	Base.onLoad()

$(document).foundation()
