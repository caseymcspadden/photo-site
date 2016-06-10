BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	events:
		"change #shipping" : "shippingChanged"


	initialize: (options) ->
		this.template = templates['checkout-view']
		this.listenTo this.collection, 'reset', this.render
		this.shipping = []
		this.subtotal = 0
		self = this
		$.get(config.servicesBase + '/shipping', (json) ->
			self.shipping = json
		)

	shippingChanged: ->
		shipping = parseInt(this.$('#shipping').val())
		for item in this.shipping
			if (item.id==shipping)
				this.$('.total').html (this.subtotal/100 + item.price).toFixed(2)


	render: ->
		data = {count: 0, subtotal: 0, shipping: this.shipping, shippingtype: 1}

		this.collection.each (item) ->
			quantity = item.get 'quantity'
			price = item.get 'price'
			data.count += quantity
			data.subtotal += price*quantity
			stype = item.get 'shippingtype'
			data.shippingtype = stype if stype > data.shippingtype

		this.subtotal = data.subtotal
		this.$el.html this.template(data)
		this.shippingChanged()
		this