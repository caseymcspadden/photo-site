Backbone = require 'backbone'
Container = require './container'

module.exports = Backbone.Collection.extend
	model: Container
	url: ->
		this.urlBase + '/services/containers/'		 

	comparator: 'position'

	initialize: (attributes, options) ->
		this.urlBase = options.urlBase
		this.masterPhotoCollection = options.masterPhotoCollection
