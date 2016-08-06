Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	defaults:
		orderid: ''
		idpwinty: 0
		idpayment: 0
		dt: ''
		name: ''
		address: ''
		address2: ''
		city: ''
		state: ''
		zip: ''
		items: 0
		amount: 0
		shipping: 0
		cardnumber: ''
		status: ''
		shipments: []

	initialize: (options) ->
		this.items = new Backbone.Collection

	retrieve: (orderid)->
		self = this
		this.items.url = config.servicesBase + '/orders/' + orderid + '/items'
		$.get(config.servicesBase + '/orders/' + orderid, (json) ->
				self.set json
				self.items.fetch {reset: true}
			)		
	

