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
		this.idcontainer = 0
		this.idphoto = 0
		this.containerProducts = new ContainerProducts
		this.listenTo this.containerProducts, 'reset', this.addAll

	render: ->
		this.$el.html this.template()

	open: (idphoto, idcontainer, cartitem) ->
		this.cartitem = cartitem
		this.idphoto = idphoto
		this.updateProducts idcontainer, idphoto
		this.$el.foundation 'open'

	updateProducts: (idcontainer, idphoto) ->
		if (idcontainer != this.idcontainer or idphoto != this.idphoto)
			this.idcontainer = idcontainer
			this.idphoto = idphoto
			this.containerProducts.update this.idcontainer, this.idphoto

	selectProduct: (e) ->
		e.preventDefault()
		idproduct = this.$('#products').val()
		if this.cartitem
			this.cartitem.save {idproduct: idproduct, wait: true}
		else
			test = this.cart.where {idphoto: this.idphoto}
			if test.length==0
				this.cart.create {idcontainer: this.idcontainer, idphoto: this.idphoto, idproduct: idproduct}
		this.$el.foundation 'close'

	addOne: (product) ->
		price = product.get('price')/100
		$option = $("<option></option>").attr("value",product.id).text(product.get('description') + ': $' + price.toFixed(2))		
		if this.cartitem and this.cartitem.get('idproduct') == product.id
			$option.attr 'selected' , true
		this.$('#products').append $option

	addAll: (collection) ->
		this.$('#products').html ''
		this.containerProducts.each this.addOne, this	