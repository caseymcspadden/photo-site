Backbone = require 'backbone'
Gallery = require './gallery'
config = require './config'

module.exports = Backbone.Collection.extend
	model: Gallery
	url: config.urlBase + '/services/portfolio'		 

	comparator: 'position'

