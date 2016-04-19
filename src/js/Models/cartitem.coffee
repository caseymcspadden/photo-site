Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	defaults:
		quantity: 1
		cropx: 0
		cropy: 0
		cropwidth: 0
		cropheight: 0
