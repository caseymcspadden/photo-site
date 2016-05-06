Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	defaults :
		band: ''
		description: ''
		isTracked: ''
		priceGPB: 0
		priceUSD: 0

