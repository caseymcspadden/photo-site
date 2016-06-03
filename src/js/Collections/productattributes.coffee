Backbone = require 'backbone'
ProductAttribute = require './productattribute'
config = require './config'

module.exports = Backbone.Collection.extend
	model: ProductAttribute
	url: config.servicesBase + '/productattributes'
