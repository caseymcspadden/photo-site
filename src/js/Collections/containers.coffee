Backbone = require 'backbone'
Container = require './container'
config = require './config'

module.exports = Backbone.Collection.extend
	model: Container
	url: config.servicesBase + '/containers'		 

	comparator: 'position'

	initialize: (attributes, options) ->
		this.masterPhotoCollection = options.masterPhotoCollection if options
