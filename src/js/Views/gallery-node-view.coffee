Backbone = require 'backbone'
templates = require './jst'

module.exports = Backbone.View.extend
	tagName: 'li'

	className: 'gallery mtree-node'

	id: ->
		'gallery-' + this.model.id

	initialize: (options) ->
		this.template = templates['gallery-node-view']
		this.listenTo this.model, 'change:name', this.render
		this.listenTo this.model, 'destroy', this.remove

	render: ->
		console.log "Rendering gallery"
		this.$el.html this.template(this.model.toJSON())
		this
