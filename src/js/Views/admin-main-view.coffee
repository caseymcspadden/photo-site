#Folders View manages a collection of folders

Backbone = require 'backbone'
templates = require './jst'
Containers = require './containers'
Container = require './container'
Admin = require './admin'
FolderView = require './folder-view'
GalleryView = require './gallery-view'

module.exports = Backbone.View.extend

	initialize: (options) ->
		this.template = templates['admin-main-view']

		this.listenTo this.model, 'change:selectedContainer', this.setVisibility

		this.folderView = new FolderView {model: this.model}
		this.galleryView = new GalleryView {model: this.model}

	assign: (view, selector) ->
		view.setElement(this.$(selector)).render();

	render: ->
		console.log "Rendering admin-main-view"
		this.$el.html this.template()
		this.assign this.folderView, '#admin-folder'
		this.assign this.galleryView, '#admin-gallery'
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



