Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	defaults :
		api: ''
		idapi: ''
		type: ''
		description: ''
		hsize: 0
		vsize: 0
		hsizeprod: 0
		vsizeprod: 0
		hres: 0
		vres: 0
		price: 0
		shippingtype: ''
		active: ''


