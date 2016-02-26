#Gallery View manages a gallery or folder

Backbone = require 'backbone'
templates = require './jst'
Photos = require './photos'
PhotoView = require './photo-view'

module.exports = Backbone.View.extend

	initialize: (options) ->
		this.template = templates['admin-photos-view']
		this.$el.html this.template()
		this.listenTo this.model.photos, 'reset', this.addAll
		this.listenTo this.model.photos, 'add', this.addOne

	render: ->
		this.addAll()

	addOne: (photo) ->
		view = new PhotoView {model: photo}
		view.render()
		this.$('#admin-photos').append view.el

	addAll: ->
		this.$('#admin-photos').html ''
		this.model.photos.each this.addOne, this
