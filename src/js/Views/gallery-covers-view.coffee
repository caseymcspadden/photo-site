Backbone = require 'backbone'
Photo = require './photo'
templates = require './jst'
config = require './config'

module.exports = Backbone.View.extend
	tagName: 'div'

	className: 'large-6 small-12 columns gallery-cover'

	id: ->
		'gallery-photo-' + this.model.id

	events:
		'click img' : 'photoClicked'
		'mouseover' : 'setFocus'

	initialize: (options) ->
		this.photoViewer = options.viewer
		this.urlBase = config.urlBase
		this.template = templates['photo-view']
		this.listenTo this.model, 'change:selected', this.setSelected
		this.listenTo this.model, 'remove', this.removeView
		this.render()
		downloadingImage = new Image
		self = this	
		downloadingImage.onload = ->
			self.$('img')[0].src = downloadingImage.src
		downloadingImage.src = this.urlBase + '/photos/T/' + this.model.uid + '.jpg'

	setFocus: (e) ->
		this.$('a').focus()

	render: ->
		obj = this.model.toJSON()
		obj.urlBase = this.urlBase
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
