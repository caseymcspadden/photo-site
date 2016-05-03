Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	defaults:
		idproduct: 0
		quantity: 1
		cropx: 0
		cropy: 0
		cropwidth: 100
		cropheight: 100
