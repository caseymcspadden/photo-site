BaseView = require './base-view'
templates = require './jst'
config = require './config'
GalleryGridView = require './gallery-grid-view'
GalleryPhotoView = require './gallery-photo-view'

module.exports = BaseView.extend

	initialize: (options) ->
		this.template = templates['gallery-main-view']
		this.galleryGridView = new GalleryGridView options
		this.galleryPhotoView = new GalleryPhotoView options

	render: ->
		this.$el.html this.template()
		this.assign this.galleryGridView, '.gallery-grid-view'
		this.assign this.galleryPhotoView, '.gallery-photo-view'
		this