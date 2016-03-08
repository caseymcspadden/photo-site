Backbone = require 'backbone'
templates = require './jst'
Photo = require './photo'

module.exports = Backbone.View.extend
	tagName: 'div'

	initialize: (options) ->
		console.log "Initializing photo viewer"
		this.template = templates['photoviewer-view']
		this.listenTo this.model, 'change:index', this.indexChanged
		this.listenTo this.model, 'change:gallery', this.galleryChanged
		this.render()

	render: ->
		this.$el.html this.template()

	indexChanged: (model) ->
		console.log "index changed"
		index = model.get('index')
		photo = model.get('gallery').photos.at(index)
		this.$('.view-image').attr('src' , 'photos/L/' + photo.id + '.jpg')

	galleryChanged: (model) ->
		console.log model.get('gallery')
		model.set {index: 0}

	viewModel: (model) ->
		console.log model
		this.model.set {index: this.model.get('gallery').photos.indexOf(model)}
