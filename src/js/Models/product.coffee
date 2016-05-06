Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	defaults :
		name: ''
		description: ''
		imageHorizontalSize: 0
		imageVerticalSize: 0
		fullProductionHorizontalSize: 0
		fullProductionVerticalSize: 0
		recommendedHorizontalResolution: 0
		recommendedVerticalResolution: 0
		sizeUnits: 'inches'
		itemType: ''
		priceGPB: 0
		priceUSD: 0
		shippingBand: ''
		attributes: []


