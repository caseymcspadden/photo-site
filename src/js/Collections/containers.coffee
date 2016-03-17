Backbone = require 'backbone'
Container = require './container'

module.exports = Backbone.Collection.extend
	model: Container
	url: "services/containers/"
	comparator: 'position'