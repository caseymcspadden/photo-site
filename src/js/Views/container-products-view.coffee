BaseView = require './base-view'
templates = require './jst'
ContainerProducts = require './containerproducts'
config = require './config'

module.exports = BaseView.extend
	events:
		'click .select-product' : 'selectProduct'

	initialize: (options) ->
		this.template = templates['container-products-view']
		#this.cart = options.cart		
		this.onSelect = options.onSelect
		this.context = options.context		
		this.containerProducts = new ContainerProducts
		this.listenTo this.containerProducts, 'reset', this.addAll

	render: ->
		this.$el.html this.template()

	open: ->
		this.$el.foundation 'open'

	updateProducts: (idcontainer) ->
		this.containerProducts.update idcontainer

	selectProduct: (e) ->
		e.preventDefault()
		this.onSelect(this.$('#products').val(), this.context)
		this.$el.foundation 'close'

		###
		photo = this.model.get 'currentPhoto'
		test = this.cart.where {idphoto: photo.id}
		if test.length==0
			this.cart.create {idcontainer: this.model.id, idphoto: photo.id, idproduct: this.$('#products').val()}
			this.$el.foundation 'close'		
		###

	addOne: (product) ->
		console.log product
		type = product.get 'type'
		if (type=='Print' or type=='Poster' or type=='Canvas')
			price = product.get('price')/100
			$option = $("<option></option>").attr("value",product.id).text(product.get('description') + ': $' + price.toFixed(2))		
			this.$('#products').append $option

	addAll: (collection) ->
		this.$('#products').html ''
		this.containerProducts.each this.addOne, this	