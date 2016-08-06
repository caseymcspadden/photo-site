BaseView = require './base-view'
templates = require './jst'
config = require './config'
OrderItemView = require './orderitem-view'

module.exports = BaseView.extend
	initialize: (options) ->
		this.template = templates['order-view']
		this.listenTo this.model, 'change', this.render
		this.listenTo this.model.items, 'reset', this.addAll

	render: ->
		data = this.model.toJSON()
		this.$el.html this.template(data)
	
	addOne: (item) ->
		orderItemView = new OrderItemView {model: item, orderid: this.model.get 'orderid'}
		this.$('.order-items').append orderItemView.render().el

	addAll: (collection) ->
		this.$('.order-items').html ''
		this.model.items.each this.addOne, this		
