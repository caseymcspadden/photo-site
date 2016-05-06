BaseView = require './base-view'
templates = require './jst'
config = require './config'
#EditUserView = require './edit-user-view'

module.exports = BaseView.extend
	events:
		'click .update-catalog' : 'updateCatalog'

	initialize: (options) ->
		this.template = templates['admin-products-view']
		#this.editUserView = new EditUserView {collection: this.collection}
		this.productTemplate = templates['admin-products-row-view']
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
		this.$('.products').append this.productTemplate product.toJSON()

	addAll: ->
		this.collection.each this.addOne, this
