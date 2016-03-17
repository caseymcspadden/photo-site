Backbone = require 'backbone'
templates = require './jst'
Gallery = require './gallery'

module.exports = Backbone.View.extend
	tagName: 'div'

	#className: 'featured-thumbnail'

	id: ->
		'gallery-' + this.model.id

	#events:
	#	'click img' : 'galleryClicked'

	initialize: (options) ->
		this.template = templates['featured-view']
		this.listenTo this.model, 'change', this.render

	render: ->
		json = this.model.toJSON()
		json.imageSource = this.model.featuredPhotoSource()	
		this.$el.html this.template(json)

	removeView: ->
		console.log "removing view"
		this.$el.remove()

	#galleryClicked: (e) ->
	#	e.preventDefault()
