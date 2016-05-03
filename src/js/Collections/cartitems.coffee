Backbone = require 'backbone'
CartItem = require './cartitem'
config = require './config'

module.exports = Backbone.Collection.extend
	model: CartItem
	url: config.servicesBase + '/cart'		 
