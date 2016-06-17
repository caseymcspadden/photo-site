BaseView = require './base-view'
templates = require './jst'
ContainerProducts = require './containerproducts'
ChoosePhotosView = require './choose-photos-view'
config = require './config'


# model = gallery
module.exports = BaseView.extend
	events:
		'click .select-product' : 'selectProduct'
		'closed.zf.reveal' : 'closed'		

	initialize: (options) ->
		this.template = templates['container-products-view']
		this.cart = options.cart
		this.idcontainer = 0
		this.idphoto = 0
		this.containerProducts = new ContainerProducts
		this.photos = if this.model then this.model.photos else null
		this.choosePhotosView = new ChoosePhotosView {collection: this.photos}
		this.listenTo this.containerProducts, 'reset', this.addAll

	render: ->
		this.$el.html this.template()
		this.assign this.choosePhotosView, '.choose-photos-view'

	open: (idphoto, idcontainer, cartitem) ->
		this.cartitem = cartitem
		this.idphoto = idphoto
		this.updateProducts idcontainer, idphoto
		this.$el.foundation 'open'
		if this.photos
			chosenPhoto = this.photos.findWhere {id:idphoto}
			chosenPhoto.set {chosen: true}

	closed: ->
		if this.photos
			this.photos.each (photo) ->
				photo.set {chosen: false}

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
			if this.photos
				this.photos.each (photo) ->
					this.cart.create {idcontainer: this.idcontainer, idphoto: photo.id, idproduct: idproduct} if photo.get('chosen')
				, this
			else
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