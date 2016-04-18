Backbone = require 'backbone'
Photo = require './photo'
templates = require './jst'
config = require './config'

module.exports = Backbone.View.extend
	tagName: 'div'

	className: 'photo-thumbnail'

	events:
		'click img' : 'photoClicked'
		'mouseover' : 'setFocus'

	initialize: (options) ->
		this.template = templates['thumbnail-view']
		this.listenTo this.model, 'change:selected', this.setSelected
		this.listenTo this.model, 'remove', this.removeView

	setFocus: (e) ->
		this.$('a').focus()

	render: ->
		obj = this.model.toJSON()
		obj.urlBase = config.urlBase
		this.$el.html this.template(obj)

		if this.model.get('selected')
			this.$('img').addClass 'selected'
		this

	removeView: ->
		this.$el.remove()

	setSelected: ->
		if this.model.get 'selected'
			this.$('img').addClass('selected')
		else
			this.$('img').removeClass('selected')

	photoClicked: (e) ->
		this.model.set 'selected', !this.model.get('selected')
		e.preventDefault()
