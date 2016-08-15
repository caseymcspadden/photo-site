Backbone = require 'backbone'
BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend

	events:
		'click .copy-photos' : 'copyPhotos'

	initialize: (options) ->
		this.template = templates['copyphotos-view']
		this.containers = new Backbone.Collection null , {comparator: 'path'}
		this.containers.url = config.servicesBase + '/containerpaths'
		this.listenTo this.containers, 'reset', this.initializeSelect

	render: ->
		this.$el.html this.template()
	
	open: ->
		this.containers.fetch {reset: true}
		this.$el.foundation 'open'

	initializeSelect: (collection) ->
		$select = this.$('#galleries')
		$select[0].options.length = 0
		selectedId = this.model.get('selectedContainer').id

		collection.each( (container) ->
			if (selectedId != container.id and container.get('type') == 'gallery')
				$option = $("<option></option>").attr("value",container.id).text(container.get('path'))
				$select.append($option)
		, this)
	
	copyPhotos: (e) ->
		e.preventDefault()
		selectedContainer = this.model.get 'selectedContainer'
		selectedContainer.addSelectedPhotosToGallery this.$('#galleries').val() , this.$('#remove').is(':checked')
		this.$el.foundation 'close'

