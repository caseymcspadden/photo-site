Backbone = require 'backbone'
templates = require './jst'
config = require './config'

module.exports = Backbone.View.extend
	id: ->
		'container-' + this.model.id

	initialize: (options) ->
		this.template = templates['container-view']
		this.listenTo this.model, 'change:name change:access change:featuredPhoto change:buyprints', this.render
		this.listenTo this.model, 'remove', this.remove

	featuredPhotoSource: ->
		if this.model.get('featuredphoto')
			return config.urlBase + '/photos/T/' + this.model.get('uid') + '.jpg'
		else if this.model.get('type') == 'folder' 
			return config.urlBase + '/images/thumbnail-folder.jpg'
		return config.urlBase + '/images/thumbnail-gallery.jpg'		

	render: ->
		json = this.model.toJSON()
		json.imageSource = this.featuredPhotoSource()	
		this.$el.html this.template(json)
