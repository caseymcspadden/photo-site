Backbone = require 'backbone'
Folder = require './folder'

module.exports = Backbone.Collection.extend
	model: Folder
	url: "services/folders/"
