Backbone = require 'backbone'
Photo = require './photo'
templates = require './jst'

module.exports = Backbone.View.extend
	tagName: 'div'

	className: 'photo-thumbnail'

	id: ->
		'gallery-photo-' + this.model.id

	events:
		'click img' : 'photoClicked'
		'mouseover' : 'setFocus'

	initialize: (options) ->
		this.photoViewer = options.viewer
		this.template = templates['photo-view']
		this.listenTo this.model, 'change:selected', this.setSelected
		this.listenTo this.model, 'remove', this.removeView
		this.render()
		downloadingImage = new Image
		self = this	
		downloadingImage.onload = ->
			self.$('img')[0].src = downloadingImage.src
		downloadingImage.src = 'photos/T/' + this.model.id + '.jpg'

	setFocus: (e) ->
		console.log "setting focus"
		this.$('a').focus()

	render: ->
		this.$el.html this.template(this.model.toJSON())

		if this.model.get('selected')
			this.$('img').addClass 'selected'

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
