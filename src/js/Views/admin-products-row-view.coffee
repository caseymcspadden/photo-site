BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	tagName: 'tr'

	events:
		'click .isactive' : 'isActiveClicked'
		'click .edit-product' : 'editProduct'		

	initialize: (options) ->
		this.template = templates['admin-products-row-view']
		this.editProductView = options.editProductView
		this.listenTo this.model, 'change', this.render

	isActiveClicked: (e) ->
		this.model.set 'active' , !this.model.get('active')
		this.model.save()

	render: ->
		this.$el.html this.template(this.model.toJSON())
		this

	editProduct: (e) ->
		this.editProductView.open(this.model.collection, this.model)
		e.preventDefault()

