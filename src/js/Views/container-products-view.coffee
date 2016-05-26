BaseView = require './base-view'
templates = require './jst'
ContainerProducts = require './containerproducts'
config = require './config'

module.exports = BaseView.extend

	events:
		'click .select-product' : 'selectProduct'

	initialize: (options) ->
		this.template = templates['container-products-view']
		this.cart = options.cart		
		this.containerProducts = new ContainerProducts
		this.listenTo this.model, 'change:buyprints', this.updateProducts
		this.listenTo this.containerProducts, 'reset', this.addAll

	updateProducts: (m) ->
		this.containerProducts.url = config.urlBase + '/bamenda/containers/' + m.id + '/products'
		this.containerProducts.fetch {reset: true}

	render: ->
		this.$el.html this.template()

	open: ->
		this.$el.foundation 'open'

	selectProduct: (e) ->
		e.preventDefault()
		photo = this.model.get 'currentPhoto'
		test = this.cart.where {idphoto: photo.id}
		if test.length==0
			this.cart.create {idcontainer: this.model.id, idphoto: photo.id, idproduct: this.$('#products').val()}
			this.$el.foundation 'close'		
			#this.$('.buy-print').addClass('in-cart')

	addOne: (product) ->
		price = product.get('price')/100
		$option = $("<option></option>").attr("value",product.id).text(product.get('description') + ': $' + price.toFixed(2))		
		this.$('#products').append $option

	addAll: (collection) ->
		this.$('#products').html ''
		this.containerProducts.each this.addOne, this	