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
		json.imageSource = if json.featuredPhoto!='0' then 'photos/T/' + json.featuredPhoto + '.jpg' else 'images/0_T.jpg'
		this.$el.html this.template(json)

	removeView: ->
		this.$el.remove()

	#galleryClicked: (e) ->
	#	e.preventDefault()
