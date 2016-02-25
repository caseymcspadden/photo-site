#Gallery View manages a gallery or folder

Backbone = require 'backbone'
templates = require './jst'
Folders = require './folders'
Folder = require './folder'
Gallery = require './gallery'
PhotoView = require './photo-view'

module.exports = Backbone.View.extend
	currentGallery: null
	photoViews: []

	initialize: (options) ->
		this.template = templates['gallery-view']

	changeGallery: (g) ->
		this.stopListening()
		this.currentGallery = g
		this.render()

		if this.currentGallery
			this.listenTo this.currentGallery.get('photos'), 'reset', this.addAll 
			this.listenTo this.currentGallery.get('photos'), 'add', this.addOne
			this.addAll()

	render: ->
		if this.currentGallery
			this.$el.html this.template(this.currentGallery.toJSON())

	addOne: (photo) ->
		view = new PhotoView {model:photo}
		view.render()
		this.$('#photo-list').append view.el

	addAll: ->
		this.$('#photo-list').html ''
		this.currentGallery.get('photos').each this.addOne, this
