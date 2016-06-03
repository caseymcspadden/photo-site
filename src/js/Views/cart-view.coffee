BaseView = require './base-view'
templates = require './jst'
config = require './config'
CartItemView = require './cartitem-view'
OrderSummaryView = require './order-summary-view'
CropView = require './crop-view'
ProductAttributes = require './productattributes'

module.exports = BaseView.extend
	initialize: (options) ->
		this.template = templates['cart-view']
		this.cropView = new CropView
		this.orderSummaryView = new OrderSummaryView {collection: this.collection}
		this.productAttributes = new ProductAttributes
		this.productAttributes.fetch()
		this.listenTo this.collection, 'reset', this.addAll

	render: ->
		this.$el.html this.template()
		this.assign this.cropView, '.crop-view'		
		this.assign this.orderSummaryView, '.order-summary-view'		

	addOne: (item) ->
		view = new CartItemView {model: item, cropView: this.cropView, productAttributes: this.productAttributes}
		view.render()
		this.$('.cart-items').append view.el

	addAll: ->
		this.$('.cart-items').html ''
		this.collection.each this.addOne, this		
