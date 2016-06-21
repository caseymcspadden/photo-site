BaseView = require './base-view'
templates = require './jst'
config = require './config'
CroppedView = require './cropped-view'

#Model: cartitem

module.exports = BaseView.extend
	attributes:
		class: 'large-12 columns cart-item'

	events:
		'click .change-product' : 'changeProduct'
		'click .decrease-quantity' : 'decreaseQuantity'
		'click .increase-quantity' : 'increaseQuantity'
		'click .crop-item' : 'cropItem'
		'click .remove-item' : 'removeItem'
		'change select' : 'changeAttribute'

	initialize: (options) ->
		this.template = templates['cartitem-view']
		this.cropView = options.cropView
		this.productAttributes = options.productAttributes
		this.containerProductsView = options.containerProductsView
		this.croppedView = new CroppedView {model: this.model, width: 340, height: 220, cropView: options.cropView}
		this.listenTo this.model, 'change:quantity', this.quantityChanged
		this.listenTo this.model, 'change:idproduct', this.productChanged
		this.listenTo this.model, 'destroy', this.remove

	render: ->
		data = this.model.toJSON()
		data.attributes = []
		attributes = this.productAttributes.where {idproduct: data.idproduct}
		data.attributes.push attributes[i].toJSON() for i in [0...attributes.length]
		this.$el.html this.template(data)
		this.assign this.croppedView, '.cropped-view'

	changeProduct: (e) ->
		e.preventDefault()
		this.containerProductsView.open this.model.get('idphoto') , this.model.get('idcontainer'), this.model

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
			this.model.save {quantity: quantity-1}

	increaseQuantity: (e) ->
		e.preventDefault();
		quantity = this.model.get 'quantity'	
		this.model.save {quantity: quantity+1}

	changeAttribute: ->
		attributes = {}
		this.$('select').each (index) ->
			attributes[$(this).attr 'name'] = $(this).val()
		this.model.save {attrs: JSON.stringify(attributes)}

	productChanged: ->
		this.render()
		this.changeAttribute()
		
	quantityChanged: ->
		price = this.model.get 'price'
		quantity = this.model.get 'quantity'
		this.$('.quantity').html this.model.get('quantity')
		this.$('.total-price').html (price*quantity/100).toFixed(2)
