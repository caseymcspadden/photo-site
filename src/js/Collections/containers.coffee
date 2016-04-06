Backbone = require 'backbone'
Container = require './container'
config = require './config'

module.exports = Backbone.Collection.extend
	model: Container
	url: config.urlBase + '/services/containers'		 

	comparator: 'position'

	initialize: (attributes, options) ->
		this.masterPhotoCollection = options.masterPhotoCollection
