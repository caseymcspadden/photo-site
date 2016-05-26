Backbone = require 'backbone'
Product = require './product'
config = require './config'

module.exports = Backbone.Collection.extend
	model: Product
