BaseView = require './base-view'
templates = require './jst'
config = require './config'
PhotoView = require './photo-view'
DownloadGalleryView = require './download-gallery-view'

module.exports = BaseView.extend

	events:
		'click .prev' : 'shiftLeft'
		'click .next' : 'shiftRight'
		'click img' : 'viewImage'
		'click .tool-download' : 'downloadGallery'
		'click .download-photo' : 'downloadPhoto'
		'click .buy-print' : 'buyPrint'
		'keyup' : 'keyUp'

	initialize: (options) ->
		this.cart = options.cart
		this.template = templates['gallery-photo-view']
		this.photoView = new PhotoView {model: this.model}
		this.downloadGalleryView = new DownloadGalleryView {model: this.model}
		this.listenTo this.model, 'change:currentPhoto', this.changePhoto
		this.listenTo this.model, 'change:downloadgallery change:maxdownloadsize change:buyprints', this.updateAccess
		#this.listenTo this.model.photos, 'reset', this.render

	render: ->
		data = this.model.toJSON()
		data.urlBase = config.urlBase
		this.$el.html this.template data
		this.assign this.photoView, '.photo-view'
		this.assign this.downloadGalleryView, '.download-gallery-view'
		this

	updateAccess: (m) ->
		this.$('.tool-download').removeClass('hide') if m.get('downloadgallery')
		this.$('.download-photo').removeClass('hide') if m.get('maxdownloadsize')>0
		this.$('.buy-print').removeClass('hide') if m.get('buyprints')

	viewImage: (e) ->
		e.preventDefault()
		this.photoView.open()

	downloadGallery: (e) ->
		e.preventDefault()
		this.downloadGalleryView.open()

	downloadPhoto: (e) ->
		e.preventDefault()
		console.log 'download photo'

	buyPrint: (e) ->
		e.preventDefault()
		photo = this.model.get 'currentPhoto'
		test = this.cart.where {idphoto: photo.id}
		if test.length==0
			this.cart.create {idcontainer: this.model.id, idphoto: photo.id, idproduct: 1}
			this.$('.buy-print').addClass('in-cart')			

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

	changePhoto: (m) ->
		photo = m.get 'currentPhoto'
		this.$('.content img').attr 'src' , config.urlBase + '/photos/M/' + photo.id + '.jpg'
		test = this.cart.where {idphoto: photo.id}
		if test.length==0
			this.$('.buy-print').removeClass('in-cart')
		else
			this.$('.buy-print').addClass('in-cart')
		this.updateCounter()
