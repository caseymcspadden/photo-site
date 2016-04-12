#Folders View manages a collection of folders

BaseView = require './base-view'
templates = require './jst'
Containers = require './containers'
Container = require './container'
#Admin = require './admin'
FolderView = require './admin-folder-view'
GalleryView = require './admin-gallery-view'
MasterThumbnailsView = require './master-thumbnails-view'
PhotoViewer = require './photoviewer-view'

module.exports = BaseView.extend

	initialize: (options) ->
		this.template = templates['admin-main-view']

		this.listenTo this.model, 'change:selectedContainer', this.setVisibility

		this.folderView = new FolderView {model: this.model}
		this.galleryView = new GalleryView {model: this.model}
		this.masterThumbnailsView = new MasterThumbnailsView {model: this.model}
		this.photoViewer = new PhotoViewer {model: this.model}

	render: ->
		this.$el.html this.template()
		this.assign this.folderView, '#admin-folder'
		this.assign this.galleryView, '#admin-gallery'
		this.assign this.masterThumbnailsView, '#admin-thumbnails'
		this.assign this.photoViewer, '#admin-photoviewer'
		this.setVisibility()

	setVisibility: ->
		if !this.model.get('selectedContainer')
			this.$('#admin-gallery').hide()
			this.$('#admin-folder').hide()
		else if this.model.get('selectedContainer').get('type')=='gallery'
			this.$('#admin-folder').hide()
			this.$('#admin-gallery').show()
		else if this.model.get('selectedContainer').get('type')=='folder'
			this.$('#admin-gallery').hide()
			this.$('#admin-folder').show()



