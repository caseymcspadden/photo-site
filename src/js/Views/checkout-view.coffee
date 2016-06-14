BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	events:
		'submit form' : 'submitForm'
		"change #shipping" : "shippingChanged"
		"click .featured-photo" : "updateFeaturedPhoto"

	initialize: (options) ->
		this.template = templates['checkout-view']
		this.listenTo this.collection, 'reset', this.render
		this.shipping = []
		this.subtotal = 0
		self = this
		this.photoIndex = 0
		$.get(config.servicesBase + '/shipping', (json) ->
			self.shipping = json
		)

	submitForm: (e) ->
		e.preventDefault();
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value
		$.ajax(
			url: config.servicesBase +  '/orders'
			type: 'POST'
			context: this
			data: data
			success: (json) ->
				console.log json
		)

	updateFeaturedPhoto: (e) ->
		this.photoIndex += 1
		if (this.photoIndex>=this.collection.length)
			this.photoIndex = 0
		idphoto= this.collection.at(this.photoIndex).get('idphoto')
		this.$('.featured-photo').attr 'src' , config.urlBase + '/photos/S/' + idphoto + '.jpg'

	shippingChanged: ->
		shipping = parseInt(this.$('#shipping').val())
		for item in this.shipping
			if (item.id==shipping)
				this.$('.total').html ((this.subtotal+item.price)/100).toFixed(2)

	render: ->
		console.log "rendering checkout-view"
		data = 
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
		this.shippingChanged()
		this