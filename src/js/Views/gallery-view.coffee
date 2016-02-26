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

	initialize: (options) ->
		this.template = templates['gallery-view']
		console.log "Inititalizing GalleryView"

	changeGallery: (g) ->
		this.stopListening()
		this.currentGallery = g
		this.render()

		if this.currentGallery
			this.listenTo this.currentGallery.photos, 'reset', this.addAll 
			this.listenTo this.currentGallery.photos, 'add', this.addOne
			this.addAll()

	render: ->
		if this.currentGallery
			this.$el.html this.template(this.currentGallery.toJSON())

	addOne: (photo) ->
		if !(this.photoViews.hasOwnProperty photo.id)
			this.photoViews[photo.id] = new PhotoView {model:photo}
		view = this.photoViews[photo.id]
		view.render()
		this.$('#photo-list').append view.el

	addAll: ->
		this.$('#photo-list').html ''
		this.currentGallery.photos.each this.addOne, this
