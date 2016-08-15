$ = require 'jquery'
require 'foundation'
Order = require('../../require/order')
OrderView = require('../../require/order-view')
Base = require '../../require/base'

Base.initialize '.session-menu', '.cart-summary-view'

orderid = document.location.pathname.replace(/^.*\/orders\//,'')

order = new Order
orderView = new OrderView {model: order, el: '.order-view'}

$ ->
	Base.onLoad()
	order.retrieve(orderid)

$(document).foundation()
