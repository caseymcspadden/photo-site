Backbone = require 'backbone'
templates = require './jst'
config = require './config'
PhotoView = require './photo-view'

module.exports = Backbone.View.extend

	initialize: (options) ->
		this.listenTo this.model.photos, 'reset', this.addAll

	addOne: (photo) ->
		photoView = new PhotoView {model: photo}
		this.$el.append photoView.render().el

	addAll: (collection) ->
		this.$el.html ''
		collection.each this.addOne, this		
