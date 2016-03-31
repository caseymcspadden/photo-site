Backbone = require 'backbone'
Photo = require './photo'
config = require './config'

module.exports = Backbone.Collection.extend
	model: Photo
	url: config.urlBase + '/services/photos'	 
