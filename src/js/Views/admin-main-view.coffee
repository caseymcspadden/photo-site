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

	initialize: (options) ->
		this.template = templates['admin-main-view']

		this.listenTo this.model, 'change:selectedFolder', this.setVisibility
		this.listenTo this.model, 'change:selectedGallery', this.setVisibility

		this.folderView = new FolderView {model: this.model}
		this.galleryView = new GalleryView {model: this.model}

	assign: (view, selector) ->
		view.setElement(this.$(selector)).render();

	render: ->
		this.$el.html this.template()
		this.assign this.folderView, '#admin-folder'
		this.assign this.galleryView, '#admin-gallery'

	setVisibility: ->
		if this.model.get('selectedGallery')
			this.$('#admin-folder').hide()
			this.$('#admin-gallery').show()
		else if this.model.get('selectedFolder')
			this.$('#admin-gallery').hide()
			this.$('#admin-folder').show()
		else
			this.$('#admin-gallery').hide()
			this.$('#admin-folder').hide()




