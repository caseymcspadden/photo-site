Backbone = require 'backbone'
Photo = require './photo'

module.exports = Backbone.Collection.extend
	model: Photo
	url: 'photos/'

	initialize: (models, options)->
		if typeof(options) != 'undefined' and typeof(options.url) != 'undefined'
			this.url = options.url