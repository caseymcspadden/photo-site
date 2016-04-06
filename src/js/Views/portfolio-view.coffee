Backbone = require 'backbone'
templates = require './jst'
config = require './config'

module.exports = Backbone.View.extend

	initialize: (options) ->
		this.galleryTemplate = templates['gallery-cover-view']
		this.listenTo this.collection, 'add', this.addOne
		this.listenTo this.collection, 'reset', this.addAll

	addOne: (gallery) ->
		data = gallery.toJSON()
		data.urlBase = config.urlBase
		html = this.galleryTemplate data
		this.$el.append html

	addAll: (collection) ->
		this.$el.html ''
		collection.each this.addOne, this		
