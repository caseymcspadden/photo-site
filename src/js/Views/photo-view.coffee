Backbone = require 'backbone'
templates = require './jst'
Photo = require './photo'

module.exports = Backbone.View.extend
	tagName: 'li'

	className: 'photo-thumbnail'

	events:
		'click img' : 'photoClicked'

	initialize: (options) ->
		this.template = templates['photo-view']
		this.listenTo this.model, 'change:selected', this.toggleSelected
		this.listenTo this.model, 'remove', this.removeView

	render: ->
		this.$el.html this.template(this.model.toJSON())
		if this.model.get('selected')
			this.$('img').addClass 'selected'

	removeView: ->
		this.$el.remove()

	toggleSelected: ->
		this.$('img').toggleClass('selected')

	photoClicked: (e) ->
		this.model.set 'selected', !this.model.get('selected')
		e.preventDefault()
