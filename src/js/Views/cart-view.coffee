BaseView = require './base-view'
templates = require './jst'
config = require './config'
CartItemView = require './cartitem-view'
CropView = require './crop-view'

module.exports = BaseView.extend
	initialize: (options) ->
		this.template = templates['cart-view']
		this.cropView = new CropView
		this.listenTo this.collection, 'reset', this.addAll

	render: ->
		this.$el.html this.template()
		this.assign this.cropView, '.crop-view'		

	addOne: (item) ->
		view = new CartItemView {model: item, cropView: this.cropView}
		view.render()
		this.$('.cart-items').append view.el

	addAll: ->
		this.$('.cart-items').html ''
		this.collection.each this.addOne, this		
