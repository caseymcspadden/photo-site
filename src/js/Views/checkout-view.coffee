BaseView = require './base-view'
templates = require './jst'
config = require './config'
CartCarouselView = require './cart-carousel-view'
CheckoutShippingView = require './checkout-shipping-view'
OrderSubmitModel = require './ordersubmit'
OrderSubmitView = require './order-submit-view'


module.exports = BaseView.extend
	events:
		'submit form' : 'submitForm'

	initialize: (options) ->
		this.template = templates['checkout-view']
		this.shipping = []
		this.subtotal = 0
		this.idcart = ''
		this.cartCarouselView = new CartCarouselView {collection: this.collection}
		this.checkoutShippingView = new CheckoutShippingView {collection: this.collection}
		this.submitModel = new OrderSubmitModel
		this.orderSubmitView = new OrderSubmitView {model: this.submitModel}
		this.listenTo this.collection, 'reset', this.collectionLoaded
		this.listenTo this.submitModel, 'change', this.submitResults

	collectionLoaded: ->
		this.idcart = this.collection.at(0).get('idcart') if this.collection.length > 0
		console.log this.idcart
		this.$('input[name="cart"]').val this.idcart

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

	validateDate: (month,year) ->
		date = new Date
		if parseInt(year)==date.getFullYear() and parseInt(month) < date.getMonth()+1
			console.log 'date fails'

		return false if parseInt(year)==date.getFullYear() and parseInt(month) < date.getMonth()+1
		return true

	validateForm: (data)->
		this.$('.field-label').removeClass('error')
		this.$('.invalid').addClass('hide')
		errors = []
		errors.push "name" if !data['name']
		errors.push "address" if !data['address'] 
		errors.push "city" if !data['city']
		errors.push "card-name" if !data['card-name']
		
		errors.push "zip" if not /^\d{5}(-\d{4})?$/.test(data['zip'])	
		errors.push "email" if not /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/.test(data['email'])
		errors.push "card-number" if !this.validateCreditCard(data['card-number'])
		errors.push "expire-month" if !this.validateDate(data['expire-month'], data['expire-year'])
		errors.push "cvv2" if not /^\d{3}\d?$/.test(data['cvv2'])	

		for i in [0...errors.length]
			this.$('#form-'+errors[i] + ' .field-label').addClass('error')
			this.$('#form-'+errors[i] + ' .invalid').removeClass('hide')

		return errors.length==0


	submitForm: (e) ->
		e.preventDefault();
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value
		this.orderSubmitView.submit data
		#if this.validateForm(data)

	submitResults: (model) ->
		if (model.get 'error')
			this.$('input[name="idorder"]').val model.get('idorder')
		else
			console.log model.get('orderid')
			this.emptyCart()

	emptyCart: ->
		$.ajax(
			url: config.servicesBase +  '/cart'
			type: 'DELETE'
			context: this
			success: (json) ->
				this.collection.reset()
		)

	shippingChanged: ->
		shipping = parseInt(this.$('#shipping').val())
		for item in this.shipping
			if (item.id==shipping)
				this.$('.total').html ((this.subtotal+item.price)/100).toFixed(2)

	render: ->
		this.$el.html this.template {idcart: ''}
		this.assign this.cartCarouselView, '.cart-carousel-view'
		this.assign this.checkoutShippingView, '.checkout-shipping-view'
		this.assign this.orderSubmitView, '.order-submit-view'
		this.shippingChanged()

		this