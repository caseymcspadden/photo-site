#Gallery View manages a gallery or folder

Backbone = require 'backbone'
templates = require './jst'
Folders = require './folders'
Folder = require './folder'
Gallery = require './gallery'
PhotoApp = require './photoapp'

module.exports = Backbone.View.extend
	app: null

	initialize: (options) ->
		this.app = options.app

		this.listenTo this.app, 'change:selectedFolder', this.folderChanged
		this.listenTo this.app, 'change:selectedGallery', this.galleryChanged

	render: ->
		folder = this.app.get 'selectedFolder'
		console.log this.app.get 'selectedGallery'
		console.log folder.toJSON()
		this.$el.html(folder.get 'Name')

	folderChanged: (app) ->
		console.log 'folder changed'
		this.render()

	galleryChanged: (folder) ->
		console.log 'gallery changed'
		this.render()
