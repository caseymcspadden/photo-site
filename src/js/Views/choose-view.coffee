Backbone = require 'backbone'
templates = require './jst'
config = require './config'

module.exports = Backbone.View.extend
	tagName: 'a'

	events:
		'click img' : 'photoClicked'

	initialize: (options) ->
		this.template = templates['choose-view']
		this.listenTo this.model, 'change:chosen', this.render

	render: ->
		data = this.model.toJSON()
		data.urlBase = config.urlBase
		this.$el.html this.template(data)
		this

	photoClicked: (e) ->
		e.preventDefault()
		e.stopPropagation()
		this.model.set 'chosen', !this.model.get('chosen')
