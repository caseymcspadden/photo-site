Backbone = require 'backbone'
templates = require './jst'
Photo = require './photo'

module.exports = Backbone.View.extend
	tagName: 'div'

	className: 'photo-thumbnail'

	id: ->
		'gallery-photo-' + this.model.id

	events:
		'click img' : 'photoClicked'
		'mouseover' : 'setFocus'
		'keypress' : 'keyPressed'
		#'dblclick' : 'keyPressed'

	initialize: (options) ->
		this.photoViewer = options.viewer
		this.template = templates['photo-view']
		this.listenTo this.model, 'change:selected', this.toggleSelected
		this.listenTo this.model, 'remove', this.removeView

	setFocus: (e) ->
		this.$('a').focus()

	keyPressed: (e) ->
		console.log 'key pressed on photo ' + this.model.id
		this.photoViewer.viewModel this.model

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
