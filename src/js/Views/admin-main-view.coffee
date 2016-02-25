#Folders View manages a collection of folders

Backbone = require 'backbone'
templates = require './jst'
Folders = require './folders'
Folder = require './folder'
Gallery = require './gallery'
Admin = require './admin'
FolderView = require './folder-view'
GalleryView = require './gallery-view'

module.exports = Backbone.View.extend
	admin: null

	initialize: (options) ->
		this.admin = options.admin
		this.template = templates['admin-main-view']

		this.listenTo this.admin, 'change:selectedFolder', this.folderChanged
		this.listenTo this.admin, 'change:selectedGallery', this.galleryChanged

		this.folderView = new FolderView()
		this.galleryView = new GalleryView()

	assign: (view, selector) ->
		view.setElement(this.$(selector)).render();

	render: ->
		this.$el.html this.template()
		this.assign this.folderView, '#admin-folder'
		this.assign this.galleryView, '#admin-gallery'

	setVisibility: ->
		if this.admin.get('selectedGallery')
			this.$('#admin-folder').hide()
			this.$('#admin-gallery').show()
		else if this.admin.get('selectedFolder')
			this.$('#admin-gallery').hide()
			this.$('#admin-folder').show()
		else
			this.$('#admin-gallery').hide()
			this.$('#admin-folder').hide()

	folderChanged: (admin) ->
		console.log "admin main view folder changed"
		console.log admin.get('selectedFolder')
		this.setVisibility()
		this.folderView.changeFolder admin.get('selectedFolder')

	galleryChanged: (admin) ->
		console.log "admin main view gallery changed"
		this.setVisibility()
		this.galleryView.changeGallery admin.get('selectedGallery')




