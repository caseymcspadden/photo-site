Backbone = require 'backbone'
templates = require './jst'
Photo = require './photo'

module.exports = Backbone.View.extend
	tagName: 'li'

	className: 'photo-thumbnail'

	events:
		'mousedown img' : 'photoClicked'		

	initialize: (options) ->
		this.template = templates['photo-view']

	render: ->
		this.$el.html this.template(this.model.toJSON())

	photoClicked: (e) ->
		$(e.target).toggleClass('selected')
