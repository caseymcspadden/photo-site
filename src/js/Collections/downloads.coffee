Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Collection.extend
	url: config.servicesBase + '/downloads'		 
