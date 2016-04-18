#admin-photos-view manages all images in the database

Backbone = require 'backbone'
ThumbnailView = require './thumbnail-view'
templates = require './jst'
Photos = require './photos'

module.exports = Backbone.View.extend
	photoViews: {}

	events:
		'click .add-selected' : 'addSelected'	

	initialize: (options) ->
		this.template = templates['admin-photos-view']
		this.$el.html this.template()
		this.listenTo this.model.photos, 'reset', this.addAll
		this.listenTo this.model.photos, 'add', this.addOne
		this.listenTo this.model, 'change:addingPhotos', this.addingPhotosChanged

	render: ->
		this.$el.html this.template()

	addingPhotosChanged: ->
		adding = this.model.get('addingPhotos')
		if !adding
			this.$el.hide()
		else
			this.addAll()
			this.$el.show()

	addSelected: ->
		this.model.addSelectedPhotosToGallery()
		this.addAll()

	addOne: (photo) ->
		selectedGallery = this.model.get 'selectedGallery'
		if selectedGallery && selectedGallery.photos.get(photo.id)
			return

		if !(this.photoViews.hasOwnProperty photo.id)
			view = this.photoViews[photo.id] = new ThumbnailView {model:photo}
			view.render()

		view = this.photoViews[photo.id]
		view.delegateEvents()
		this.$('.photo-list').append view.el

	addAll: ->
		this.$('.photo-list').html ''
		this.model.photos.each this.addOne, this
