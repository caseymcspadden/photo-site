Backbone = require 'backbone'
FolderCollection = require './folders'
PhotoCollection = require './photos'
Folder = require('./folder')
Gallery = require('./gallery')

module.exports = Backbone.Model.extend
	defaults :
		selectedFolder: null
		selectedGallery: null
		folders: null
		photos: null

	initialize: (attributes, options) ->
		this.set {folders: new FolderCollection()}
		photos = new PhotoCollection
		photos.fetch()
		this.set {photos: photos}

		for folder in options.folders
			f = new Folder(folder)
			this.get('folders').add f   
			for gallery in folder.galleries
				g = new Gallery gallery,{master:photos}
				f.get('galleries').add g

	selectFolder: (id) ->
		this.set {selectedFolder: this.get('folders').get(id)}
		this.set {selectedGallery: null}

	selectGallery: (id) ->
		selectedFolder = this.get 'selectedFolder'
		gallery = null
		if selectedFolder
			gallery = selectedFolder.get('galleries').get id
			if gallery
				gallery.populate()
		this.set {selectedGallery: gallery}