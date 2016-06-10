Backbone = require 'backbone'
templates = require './jst'
config = require './config'

module.exports = Backbone.View.extend
	initialize: (options) ->
		this.template = templates['order-summary-view']
		this.listenTo this.collection, 'add change remove reset', this.render

	render: ->
		data = {count: 0, subtotal: 0}

		this.collection.each (item) ->
			quantity = item.get 'quantity'
			price = item.get 'price'
			data.count += quantity
			data.subtotal += price*quantity

		this.$el.html this.template(data)
