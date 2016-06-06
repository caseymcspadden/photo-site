BaseView = require './base-view'
templates = require './jst'
config = require './config'
AdminProductsRowView = require './admin-products-row-view'

module.exports = BaseView.extend
	events:
		'click .update-catalog' : 'updateCatalog'

	initialize: (options) ->
		this.template = templates['admin-products-view']
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

	render: ->
		this.$el.html this.template()

	addOne: (product) ->
		adminProductsRowView = new AdminProductsRowView {model: product}
		this.$('.products').append adminProductsRowView.render().el

	addAll: ->
		this.collection.each this.addOne, this
