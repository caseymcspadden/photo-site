BaseView = require './base-view'
templates = require './jst'
config = require './config'
CartItemView = require './cartitem-view'

module.exports = BaseView.extend
	initialize: (options) ->
		this.template = templates['cart-view']
		this.render()
		this.listenTo this.collection, 'reset', this.addAll

	render: ->
		this.$el.html this.template()

	addOne: (item) ->
		view = new CartItemView {model: item}
		view.render()
		this.$('.cart-items').append view.el

	addAll: ->
		this.collection.each this.addOne, this		
