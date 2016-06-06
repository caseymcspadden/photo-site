BaseView = require './base-view'
templates = require './jst'
ContainerProducts = require './containerproducts'
config = require './config'


# model = container
module.exports = BaseView.extend
	events:
		'click .select-product' : 'selectProduct'

	initialize: (options) ->
		this.template = templates['container-products-view']
		this.cart = options.cart
		this.currentContainer = 0
		this.containerProducts = new ContainerProducts
		this.listenTo this.containerProducts, 'reset', this.addAll

	render: ->
		this.$el.html this.template()

	open: (photo, idcontainer) ->
		this.photo = photo
		if (idcontainer != this.currentContainer)
			this.currentContainer = idcontainer
			this.containerProducts.update idcontainer
		this.$el.foundation 'open'

	updateProducts: (idcontainer) ->
		if (idcontainer != this.currentContainer)
			this.currentContainer = idcontainer
			this.containerProducts.update idcontainer

	selectProduct: (e) ->
		e.preventDefault()
		#this.onSelect(this.$('#products').val(), this.context)
		test = this.cart.where {idphoto: this.photo.id}
		if test.length==0
			this.cart.create {idcontainer: this.model.id, idphoto: this.photo.id, idproduct: this.$('#products').val()}
		this.$el.foundation 'close'

	addOne: (product) ->
		price = product.get('price')/100
		$option = $("<option></option>").attr("value",product.id).text(product.get('description') + ': $' + price.toFixed(2))		
		this.$('#products').append $option

	addAll: (collection) ->
		this.$('#products').html ''
		this.containerProducts.each this.addOne, this	