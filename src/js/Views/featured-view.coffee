Backbone = require 'backbone'
templates = require './jst'

module.exports = Backbone.View.extend
	tagName: 'div'

	#className: 'featured-thumbnail'

	id: ->
		'featured-' + this.model.id

	#events:
	#	'click img' : 'galleryClicked'

	initialize: (options) ->
		this.template = templates['featured-view']
		this.listenTo this.model, 'change', this.render
		this.listenTo this.model, 'remove', this.remove

	render: ->
		json = this.model.toJSON()
		json.imageSource = this.model.featuredPhotoSource()	
		this.$el.html this.template(json)
