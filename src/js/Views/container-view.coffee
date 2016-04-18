Backbone = require 'backbone'
templates = require './jst'
config = require './config'

module.exports = Backbone.View.extend
	tagName: 'div'

	#className: 'featured-thumbnail'

	id: ->
		'container-' + this.model.id

	#events:
	#	'click img' : 'galleryClicked'

	initialize: (options) ->
		this.template = templates['container-view']
		this.listenTo this.model, 'change', this.render
		this.listenTo this.model, 'remove', this.remove

	featuredPhotoSource: ->
		if this.model.get('featuredphoto') != 0 
			return config.urlBase + '/photos/T/' + this.model.get('featuredphoto') + '.jpg'
		else if this.model.get('type') == 'folder' 
			return config.urlBase + '/images/thumbnail-folder.jpg'
		return config.urlBase + '/images/thumbnail-gallery.jpg'		

	render: ->
		json = this.model.toJSON()
		json.imageSource = this.featuredPhotoSource()	
		this.$el.html this.template(json)
