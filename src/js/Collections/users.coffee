Backbone = require 'backbone'
User = require './user'
config = require './config'

module.exports = Backbone.Collection.extend
	model: User
	url: config.servicesBase + '/users'		 
