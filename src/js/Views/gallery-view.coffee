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
		folder = this.app.get 'selectedFolder'
		if not folder
			return

		gid = this.app.get 'selectedGallery'
		gallery = folder.Galleries.get gid
		if gid and gallery is undefined
			return

		console.log folder
		if gallery
			console.log gallery.getJSON()

		this.$el.html this.template(if gid then gallery.getJSON() else folder.toJSON())

	folderChanged: (app) ->
		console.log 'folder changed'
		this.render()

	galleryChanged: (folder) ->
		console.log 'gallery changed'
		this.render()

	photoClicked: (e) ->
		console.log e
