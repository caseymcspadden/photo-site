Backbone = require 'backbone'
FolderCollection = require './folders'
PhotoCollection = require './photos'
Folder = require('./folder')
Gallery = require('./gallery')

module.exports = Backbone.Model.extend
	defaults :
		selectedFolder: null
		selectedGallery: -1
		photos: null
		folders: null
	
	initialize: (attributes, options) ->
		this.photos = new PhotoCollection(options.photos)
		this.folders = new FolderCollection()

		for folder in options.folders
			f = new Folder(folder)
			this.folders.add f   
			for gallery in folder.Galleries
				g = new Gallery(gallery)
				f.Galleries.add g
				for idphoto in gallery.Photos
					p = this.photos.get(idphoto)
					g.addPhoto p

	selectFolder: (id) ->
		this.set({selectedFolder: this.folders.get(id)})

	selectGallery: (id) ->
		selectedFolder = this.get 'selectedFolder'

		if (selectedFolder)
			g = selectedFolder.Galleries.get id
			index = if g then selectedFolder.Galleries.indexOf(g) else -1
			this.set {selectedGallery: g}
			selectedFolder.set {selectedGallery: index}
