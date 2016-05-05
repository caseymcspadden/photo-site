Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	urlRoot: config.servicesBase + '/store/catalog'

	defaults :
		countryCode: ''
		country: ''
		qualityLevel: ''
		items: null
		shippingRates: null

	#initialize: (attributes, options) ->
