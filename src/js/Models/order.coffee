Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	defaults:
		dt: ''
		orderid: ''
		printid: ''
		idpwinty: 0
		idpayment: 0
		name: ''

	initialize: (options) ->
		this.orderid = options.orderid
		this.items = new Backbone.Collection
		this.items.url = config.servicesBase + '/orders/' + this.orderid + '/items'

	retrieve: ->
		self = this
		$.get(config.servicesBase + '/orders/' + this.orderid, (json) ->
				self.set json
				self.items.fetch {reset: true}
			)		
	

