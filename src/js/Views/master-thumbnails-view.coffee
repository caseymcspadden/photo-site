Backbone = require 'backbone'
templates = require './jst'
Photo = require './photo'
PhotoView = require './photo-view'

module.exports = Backbone.View.extend
	events:
		'click .add-selected' : 'addSelected'
		'keydown .thumbnails' : 'keyDown'
		'keyup .thumbnails' : 'keyUp'

	initialize: (options) ->
		this.photoViews = {}
		this.photos = new Backbone.Collection {model: Photo}
		this.selectMode = 0
		this.currentPhoto = null
		this.template = templates['master-thumbnails-view']

		this.listenTo this.photos, 'change:selected', this.selectedPhotoChanged
		this.listenTo this.photos, 'add', this.addOneThumbnail
		this.listenTo this.model, 'change:addingPhotosToggle' , this.open
		this.selectedContainer = null

	keyDown: (e) ->
		if e.keyCode == 91
			this.selectMode=2
		else if e.keyCode == 16
			this.selectMode=3

	keyUp: (e) ->
		this.selectMode = 0

	selectedPhotoChanged: (photo) ->
		return if photo.get('selected') == false 

		if this.selectMode==0
			this.photos.each (p) ->
				p.set('selected', false) if p.id != photo.id
		
		if this.selectMode==3
			this.selectMode=2
			index1 = this.photos.indexOf this.currentPhoto
			index2 = this.photos.indexOf photo
			this.photos.at(i).set('selected',true) for i in [index1 .. index2]
	
		this.currentPhoto = photo		

	open: ->
		this.selectMode = 0
		this.$el.foundation 'open'
		this.selectedContainer = this.model.get 'selectedContainer'
		this.addAllThumbnails()

	addSelected: ->
		this.model.addSelectedPhotosToContainer this.model.get('selectedContainer')
		this.$el.foundation 'close'

	render: ->
		console.log "rendering master thumbnails view"
		this.$el.html this.template()

	addOneThumbnail: (photo) ->
		if !(this.photoViews.hasOwnProperty photo.id)
			view = this.photoViews[photo.id] = new PhotoView {model:photo, id: 'master-photo-' + photo.id}
		
		view = this.photoViews[photo.id]
		this.$('.thumbnails').append view.el
		view.delegateEvents()

	filterPhoto: (photo) ->
		if this.selectedContainer.photos.indexOf(photo)<0
			this.photos.add photo

	addAllThumbnails: ->
		this.photos.reset();
		this.$('.thumbnails').html ''
		return if not this.selectedContainer or this.selectedContainer.get('type') != 'gallery'

		this.model.photos.each this.filterPhoto, this