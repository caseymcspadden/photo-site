Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	defaults:
		error: null
		idorder: 0,
		orderid: null