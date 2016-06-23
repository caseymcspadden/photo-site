BaseView = require './base-view'
templates = require './jst'
config = require './config'

#Model: orderitem

module.exports = BaseView.extend
	tagName: 'div'

	className: 'orderitem'

	###
	events:
		'click .change-product' : 'changeProduct'
		'click .decrease-quantity' : 'decreaseQuantity'
		'click .increase-quantity' : 'increaseQuantity'
		'click .crop-item' : 'cropItem'
		'click .remove-item' : 'removeItem'
		'change select' : 'changeAttribute'
	###

	initialize: (options) ->
		this.template = templates['orderitem-view']
		this.orderid = options.orderid

	render: ->
		data = this.model.toJSON()
		data.urlBase = config.urlBase
		data.orderid = this.orderid
		this.$el.html this.template(data)
		this
