Backbone = require 'backbone'
Photo = require './photo'

module.exports = Backbone.Collection.extend
	model: Photo
	url: ->
		this.urlBase + '/services/photos/'		 

	initialize: (attributes, options) ->
		this.urlBase = options.urlBase
