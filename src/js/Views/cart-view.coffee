BaseView = require './base-view'
templates = require './jst'
config = require './config'
CartItemView = require './cartitem-view'
OrderSummaryView = require './order-summary-view'
CropView = require './crop-view'
ContainerProductsView = require './container-products-view'
ProductAttributes = require './productattributes'

module.exports = BaseView.extend
	initialize: (options) ->
		this.template = templates['cart-view']
		this.cropView = new CropView
		this.containerProductsView = new ContainerProductsView {cart: this.collection}
		this.orderSummaryView = new OrderSummaryView {collection: this.collection}
		this.productAttributes = new ProductAttributes
		this.productAttributes.fetch()
		this.listenTo this.collection, 'reset', this.addAll

	render: ->
		this.$el.html this.template {urlBase: config.urlBase}
		this.assign this.cropView, '.crop-view'		
		this.assign this.orderSummaryView, '.order-summary-view'		
		this.assign this.containerProductsView, '.container-products-view'

	addOne: (item) ->
		view = new CartItemView {model: item, cropView: this.cropView, productAttributes: this.productAttributes, containerProductsView: this.containerProductsView}
		view.render()
		this.$('.cart-items').append view.el

	addAll: ->
		this.$('.cart-items').html ''
		this.collection.each this.addOne, this		
