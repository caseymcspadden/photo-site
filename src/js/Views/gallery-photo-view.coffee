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
		'keyup' : 'keyUp'

	initialize: (options) ->
		this.template = templates['gallery-photo-view']
		this.photoView = new PhotoView {model: this.model}
		this.downloadGalleryView = new DownloadGalleryView {model: this.model}
		this.listenTo this.model, 'change:currentPhoto', this.changePhoto
		this.listenTo this.model, 'change:downloadgallery', this.updateAccess
		#this.listenTo this.model.photos, 'reset', this.render

	render: ->
		data = this.model.toJSON()
		data.urlBase = config.urlBase
		console.log data
		this.$el.html this.template data
		this.assign this.photoView, '.photo-view'
		this.assign this.downloadGalleryView, '.download-gallery-view'
		this

	updateAccess: (m) ->
		this.$('.tool-download').removeClass('hide') if m.get('downloadgallery')

	viewImage: ->
		this.photoView.open()

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
		this.updateCounter()
