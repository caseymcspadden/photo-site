Backbone = require 'backbone'
templates = require './jst'
config = require './config'

module.exports = Backbone.View.extend

	initialize: (options) ->
		this.containerTemplate = templates['container-cover-view']
		this.listenTo this.model.containers, 'reset', this.addAll

	addOne: (container) ->
		data = container.toJSON()
		data.urlBase = config.urlBase
		data.containerUrl = this.model.urlBase + '/' + data.url
		html = this.containerTemplate data
		this.$el.append html

	addAll: (collection) ->
		this.$el.html ''
		this.model.containers.each this.addOne, this		
