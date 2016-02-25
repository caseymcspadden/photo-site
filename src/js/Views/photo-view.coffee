Backbone = require 'backbone'
templates = require './jst'
Photo = require './photo'

module.exports = Backbone.View.extend
	tagName: 'li'

	className: 'photo-thumbnail'

	events:
		'mousedown img' : 'photoClicked'		

	initialize: (options) ->
		console.log 'Initializing view'
		this.template = templates['photo-view']

		this.listenTo(this.model, 'change', this.render);
		this.listenTo(this.model, 'destroy', this.test);

	render: ->
		this.$el.html this.template(this.model.toJSON())

	photoClicked: (e) ->
		console.log e

	test: ->
		this.remove()
		console.log 'removing view'