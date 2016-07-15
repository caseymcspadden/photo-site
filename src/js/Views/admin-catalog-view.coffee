BaseView = require './base-view'
templates = require './jst'
config = require './config'
EditProductView = require './edit-product-view'
AdminProductsRowView = require './admin-products-row-view'

module.exports = BaseView.extend
	events:
		'click .update-catalog' : 'updateCatalog'
		'click .add-product' : 'addProduct'

	initialize: (options) ->
		this.template = templates['admin-catalog-view']
		this.editProductView = new EditProductView {collection: this.collection}
		this.listenTo this.collection, 'add', this.addOne
		this.listenTo this.collection, 'reset', this.addAll

	updateCatalog: (e) ->
		e.preventDefault()
		$.ajax(
			type: "PUT"
			url: config.servicesBase + '/catalog'
			data: {}
			dataType: 'json'
		)

	addProduct: (e) ->
		e.preventDefault()
		this.editProductView.open this.collection , null

	render: ->
		this.$el.html this.template()
		this.assign this.editProductView, '.edit-product-view'

	addOne: (product) ->
		adminProductsRowView = new AdminProductsRowView {model: product, editProductView: this.editProductView}
		this.$('.products').append adminProductsRowView.render().el

	addAll: ->
		this.collection.each this.addOne, this