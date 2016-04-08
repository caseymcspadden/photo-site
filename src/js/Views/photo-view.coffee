Backbone = require 'backbone'
Photo = require './photo'
templates = require './jst'
config = require './config'

module.exports = Backbone.View.extend
	tagName: 'div'

	className: 'photo-thumbnail'

	id: ->
		'gallery-photo-' + this.model.id

	events:
		'click img' : 'photoClicked'
		'mouseover' : 'setFocus'

	initialize: (options) ->
		this.template = templates['photo-view']
		this.listenTo this.model, 'change:selected', this.setSelected
		this.listenTo this.model, 'remove', this.removeView
		this.render()
		downloadingImage = new Image
		self = this	
		downloadingImage.onload = ->
			self.$('img')[0].src = downloadingImage.src
		downloadingImage.src = config.urlBase + '/photos/T/' + this.model.id + '.jpg'

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
