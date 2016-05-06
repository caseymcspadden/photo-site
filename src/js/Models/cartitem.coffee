Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	defaults:
		idphoto: 0
		idcontainer: 0
		idproduct: 0
		price: 0
		quantity: 1
		cropx: 0
		cropy: 0
		cropwidth: 100
		cropheight: 100
