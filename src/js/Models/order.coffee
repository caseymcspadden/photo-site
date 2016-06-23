Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend

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
	

