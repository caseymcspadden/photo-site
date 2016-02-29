#Gallery View manages a gallery or folder

Backbone = require 'backbone'
templates = require './jst'
Folders = require './folders'
Folder = require './folder'
Gallery = require './gallery'
PhotoView = require './photo-view'

module.exports = Backbone.View.extend
	currentGallery: null
	photoViews: {}

	events:
		'click .add-photos' : 'addPhotos'		

	initialize: (options) ->
		this.template = templates['gallery-view']
		this.listenTo this.model, 'change:selectedGallery', this.changeGallery
		console.log this.model

	changeGallery: ->
		console.log "Changing gallery"
		if (this.currentGallery)
			this.stopListening this.currentGallery.photos
	
		this.currentGallery = this.model.get('selectedGallery')
		this.render()

		if this.currentGallery
			this.listenTo this.currentGallery.photos, 'reset', this.addAll 
			this.listenTo this.currentGallery.photos, 'add', this.addOne
			this.addAll()

	addPhotos: ->
		this.model.set {addingPhotos: !this.model.get('addingPhotos')}

	render: ->
		if this.currentGallery
			this.$el.html this.template(this.currentGallery.toJSON())

	addOne: (photo) ->
		if !(this.photoViews.hasOwnProperty photo.id)
			view = this.photoViews[photo.id] = new PhotoView {model:photo}
			view.render()
		view = this.photoViews[photo.id]
		view.delegateEvents()
		this.$('.photo-list').append view.el

	addAll: ->
		this.$('.photo-list').html ''
		this.currentGallery.photos.each this.addOne, this
