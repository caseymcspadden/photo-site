Backbone = require 'backbone'

module.exports = Backbone.Model.extend
	defaults :
		size: 'L'
		photo: null
		collection: null	
