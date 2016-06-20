BaseView = require './base-view'
templates = require './jst'
config = require './config'
CartCarouselView = require './cart-carousel-view'

module.exports = BaseView.extend
	events:
		'submit form' : 'submitForm'
		"change #shipping" : "shippingChanged"

	initialize: (options) ->
		this.template = templates['checkout-view']
		this.listenTo this.collection, 'reset', this.render
		this.shipping = []
		this.subtotal = 0
		this.cartCarouselView = new CartCarouselView {collection: this.collection}
		self = this
		$.get(config.servicesBase + '/shipping', (json) ->
			self.shipping = json
		)

	validateCreditCard: (value) ->
		return false if /[^0-9-\s]+/.test(value)
		nCheck=0
		nDigit=0
		bEven=false
		value = value.replace /\D/g, ''
		for n in [value.length-1..0]
			nDigit = parseInt(value.charAt(n),10)
			if bEven
				nDigit-=9 if (nDigit*=2)>9
			nCheck += nDigit
			bEven = !bEven
		return (nCheck%10)==0

	submitForm: (e) ->
		e.preventDefault();
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value
		console.log this.validateCreditCard(data['card-number'])
		###
		$.ajax(
			url: config.servicesBase +  '/orders'
			type: 'POST'
			context: this
			data: data
			success: (json) ->
				console.log json
		)
		###

	shippingChanged: ->
		shipping = parseInt(this.$('#shipping').val())
		for item in this.shipping
			if (item.id==shipping)
				this.$('.total').html ((this.subtotal+item.price)/100).toFixed(2)

	render: ->
		data =
			count: 0
			subtotal: 0
			shipping: this.shipping
			shippingtype: 1
			collection: this.collection
			urlBase: config.urlBase
			idcart: ''

		this.collection.each (item) ->
			quantity = item.get 'quantity'
			price = item.get 'price'
			data.count += quantity
			data.subtotal += price*quantity
			stype = item.get 'shippingtype'
			data.shippingtype = stype if stype > data.shippingtype
			data.idcart = item.get 'idcart'

		this.subtotal = data.subtotal
		this.$el.html this.template(data)
		this.assign this.cartCarouselView, '.cart-carousel-view'
		this.shippingChanged()

		this