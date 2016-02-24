#Gallery View manages a gallery or folder

Backbone = require 'backbone'
templates = require './jst'
Folders = require './folders'
Folder = require './folder'
Gallery = require './gallery'
PhotoApp = require './photoapp'

module.exports = Backbone.View.extend
	app: null

	events:
		'click .thumbnail > img' : 'photoClicked'

	initialize: (options) ->
		this.app = options.app
		this.template = templates['gallery-view']

		this.listenTo this.app, 'change:selectedFolder', this.folderChanged
		this.listenTo this.app, 'change:selectedGallery', this.galleryChanged

	render: ->
		console.log 'rendering'
		folder = this.app.get 'selectedFolder'
		if not folder
			return

		gallery = this.app.get 'selectedGallery'

		console.log(gallery)

		if gallery is null
			return

		this.$el.html this.template(if gallery then gallery.getJSON() else folder.toJSON())

	folderChanged: (app) ->
		this.render()

	galleryChanged: (app) ->
		if app.get('selectedGallery')
			this.listenTo app.get('selectedGallery').get('photos'), 'add', this.photoAdded 

		this.render()

	photoAdded: (p) ->
		console.log p

	photoClicked: (e) ->
		console.log e
