Backbone = require 'backbone'
templates = require './jst'
config = require './config'
OrderItemView = require './orderitem-view'

module.exports = Backbone.View.extend
	initialize: (options) ->
		this.template = templates['order-view']
		this.listenTo this.model, 'change', this.render
		this.listenTo this.model.items, 'reset', this.addAll

	render: ->
		data = this.model.toJSON()
		console.log data
		this.$el.html this.template(data)
	
	addOne: (model) ->
		orderItemView = new OrderItemView {model: model, orderid: this.model.orderid}
		this.$('.order-items').append orderItemView.render().el

	addAll: (collection) ->
		this.model.items.each this.addOne, this		
