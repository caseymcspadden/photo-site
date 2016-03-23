# Gallery model contains a collection of photos

Backbone = require 'backbone'

module.exports = Backbone.Model.extend
	defaults :
		size: 'L'
		photo: null
		collection: null	
