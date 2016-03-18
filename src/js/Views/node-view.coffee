Backbone = require 'backbone'
templates = require './jst'

module.exports = Backbone.View.extend
	tagName: 'li'

	className: ->
		this.model.get('type') + ' mtree-node'

	id: ->
		'node-' + this.model.id

	initialize: (options) ->
		this.folderTemplate = templates['folder-node-view']
		this.galleryTemplate = templates['gallery-node-view']
		this.listenTo this.model, 'change:name', this.render
		this.listenTo this.model, 'destroy', this.remove

	render: ->
		template = if this.model.get('type') == 'gallery' then this.galleryTemplate else this.folderTemplate
		this.$el.html template(this.model.toJSON())
		this
