BaseView = require './base-view'
templates = require './jst'
PhotoView = require './photo-view'

module.exports = BaseView.extend

	initialize: (options) ->
		this.template = templates['gallery-grid-view']		
		this.listenTo this.model.photos, 'reset', this.addAll
		this.listenTo this.model.photos, 'change:selected', this.selectPhoto

	render: ->
		this.$el.html this.template()
		this

	selectPhoto: (m) ->
		console.log m

	addOne: (photo) ->
		photoView = new PhotoView {model: photo}
		this.$('.content').append photoView.render().el

	addAll: (collection) ->
		this.$('.content').html ''
		collection.each this.addOne, this

