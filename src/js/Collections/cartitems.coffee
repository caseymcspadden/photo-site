Backbone = require 'backbone'
CartItem = require './cartitem'

module.exports = Backbone.Collection.extend
	model: CartItem
