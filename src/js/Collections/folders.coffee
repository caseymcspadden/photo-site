Backbone = require 'backbone'
Folder = require './folder'

module.exports = Backbone.Collection.extend
	url: "services/folders/"
	model: Folder

	initialize: (models, options) ->
		console.log options