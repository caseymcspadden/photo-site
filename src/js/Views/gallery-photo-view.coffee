BaseView = require './base-view'
templates = require './jst'
config = require './config'
PhotoView = require './photo-view'
ContainerProductsView = require './container-products-view'
DownloadGalleryView = require './download-gallery-view'

module.exports = BaseView.extend

	events:
		'click .prev' : 'shiftLeft'
		'click .next' : 'shiftRight'
		'click img.selected-photo' : 'viewImage'
		'click .download-gallery' : 'downloadGallery'
		'click .download-photo' : 'downloadPhoto'
		'click .buy-product' : 'buyProduct'
		'keyup' : 'keyUp'

	initialize: (options) ->
		this.cart = options.cart
		this.template = templates['gallery-photo-view']
		this.containerProductsView = new ContainerProductsView {model: this.model, cart: options.cart}
		this.photoView = new PhotoView {model: this.model}
		this.downloadGalleryView = new DownloadGalleryView {model: this.model}
		this.listenTo this.model, 'change:buyprints', this.updateProducts
		this.listenTo this.model, 'change:currentPhoto', this.changePhoto
		this.listenTo this.model, 'change:downloadgallery change:maxdownloadsize change:buyprints', this.updateAccess
		this.listenTo this.cart, 'add' , this.cartItemAdded
		this.speed = 3000

	render: ->
		data = this.model.toJSON()
		data.urlBase = config.urlBase
		this.$el.html this.template data
		this.assign this.photoView, '.photo-view'
		this.assign this.containerProductsView, '.container-products-view'
		this.assign this.downloadGalleryView, '.download-gallery-view'
		this

	###
	updateProducts: (m) ->
		this.containerProductsView.updateProducts m.id
	###
	
	updateAccess: (m) ->
		data = this.model.toJSON()
		if (data.downloadgallery==1 || data.downloadgallery==3 || (data.downloadgallery==2 && (data.downloadfee==0 || data.idpayment!=0)))
			this.$('.download-photo').removeClass('hide')
		this.$('.download-gallery').removeClass('hide') if data.downloadgallery>1
		this.$('.buy-product').removeClass('hide') if m.get('buyprints')
	
	viewImage: (e) ->
		e.preventDefault()
		this.model.set 'showGrid' , !this.model.get('showGrid')
		if this.model.get('showGrid')
			window.clearInterval this.interval
		else
			self = this
			this.interval = window.setInterval( ->
				self.model.offsetCurrentPhoto(1)
			, this.speed)
		#this.photoView.open()

	downloadGallery: (e) ->
		e.preventDefault()
		this.downloadGalleryView.open()

	downloadPhoto: (e) ->
		e.preventDefault()
		photo = this.model.get 'currentPhoto'
		this.$('#download-iframe').attr 'src' , config.urlBase + '/downloads/file/' + this.model.id + '/' + this.model.get('urlsuffix') + '/' + photo.id

	buyProduct: (e) ->
		e.preventDefault()
		this.containerProductsView.open this.model.get('currentPhoto').id , this.model.id, null

	###
	selectProduct: (idproduct, context) ->
		photo = context.model.get 'currentPhoto'
		test = context.cart.where {idphoto: photo.id}
		if test.length==0
			context.cart.create {idcontainer: context.model.id, idphoto: photo.id, idproduct: idproduct}
	###

	keyUp: (e) ->
		offset = switch e.keyCode
			when 37 then -1
			when 38 then -3
			when 39 then 1
			when 40 then 3
			else 0
		this.model.offsetCurrentPhoto offset

	shiftLeft: ->
		this.model.offsetCurrentPhoto -1
		this.$('.content a').focus()
		
	shiftRight: ->
		this.model.offsetCurrentPhoto 1
		this.$('.content a').focus()

	updateCounter: ->
		photo = this.model.get 'currentPhoto'
		this.$('.index').html (1+this.model.photos.indexOf photo)
		this.$('.total').html this.model.photos.length

	cartItemAdded: ->
		this.$('.buy-product').addClass('in-cart')

	changePhoto: (m) ->
		photo = m.get 'currentPhoto'
		console.log m
		this.$('.content img').attr 'src' , config.urlBase + '/photos/M/' + photo.id + '.jpg'
		test = this.cart.where {idphoto: photo.id}
		if test.length==0
			this.$('.buy-product').removeClass('in-cart')
		else
			this.$('.buy-product').addClass('in-cart')
		this.updateCounter()
