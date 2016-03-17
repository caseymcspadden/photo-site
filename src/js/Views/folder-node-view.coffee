Backbone = require 'backbone'
templates = require './jst'

module.exports = Backbone.View.extend
	tagName: 'li'

	className: 'folder mtree-node'

	id: ->
		'folder-' + this.model.id

	initialize: ->
		this.template = templates['folder-node-view']
		this.listenTo this.model, 'change:name', this.render
		this.listenTo this.model, 'destroy', this.remove

	render: ->
		console.log "Rendering folder"
		this.$el.html this.template(this.model.toJSON())
		this