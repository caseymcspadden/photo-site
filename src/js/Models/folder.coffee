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

	removeGallery: (id) ->
		this.galleries.remove id
		position = 1
		this.galleries.each (g)->
			g.save {position: position++}

	addGallery: (g) ->
		this.galleries.add g
		g.save {idFolder: this.id, position: this.galleries.length-1}
