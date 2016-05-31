BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	attributes:
		class: 'large-12 columns cart-item'

	events:
		'click .crop-item' : 'cropItem'
		'click .decrease-quantity' : 'decreaseQuantity'
		'click .increase-quantity' : 'increaseQuantity'
		'click .crop-item' : 'cropItem'
		'click .remove-item' : 'removeItem'

	initialize: (options) ->
		this.template = templates['cartitem-view']
		this.cropView = options.cropView
		this.listenTo this.model, 'change:togglecrop', this.render
		this.listenTo this.model, 'change:quantity', this.quantityChanged
		this.listenTo this.model, 'destroy', this.remove
		#this.listenTo this.model.photos, 'reset', this.render

	render: ->
		console.log 'rendering cropitem'
		data = this.model.toJSON()
		imagewidth = 150 * data.width/data.height
		data.cropx *= (imagewidth/250)
		data.cropwidth *= (imagewidth/250)
		data.urlBase = config.urlBase
		this.$el.html this.template(data)

	cropItem: (e) ->
		e.preventDefault()
		this.cropView.open this.model

	removeItem: (e) ->
		e.preventDefault();
		this.model.destroy()

	decreaseQuantity: (e) ->
		e.preventDefault();
		quantity = this.model.get 'quantity'
		if quantity > 1	
			this.model.set 'quantity' , quantity - 1
			this.model.save()

	increaseQuantity: (e) ->
		e.preventDefault();
		quantity = this.model.get 'quantity'	
		this.model.set 'quantity' , quantity + 1	
		this.model.save()

	quantityChanged: ->
		price = this.model.get 'price'
		quantity = this.model.get 'quantity'
		this.$('.quantity').html this.model.get('quantity')
		this.$('.total-price').html (price*quantity/100).toFixed(2)
