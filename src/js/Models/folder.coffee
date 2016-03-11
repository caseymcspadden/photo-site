# Folder model contains a collection of galleries

Backbone = require 'backbone'
Gallery = require './gallery' 
FolderGalleries = require './foldergalleries'

module.exports = Backbone.Model.extend
	urlRoot: 'services/folders/'

	defaults :
		name: ''
		description: ''
		idfolder: '0'
		position: '0'
		
	initialize: (options) ->
		this.galleries = new FolderGalleries
