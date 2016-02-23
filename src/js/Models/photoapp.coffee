Backbone = require 'backbone'
FolderCollection = require './folders'
PhotoCollection = require './photos'
Folder = require('./folder')
Gallery = require('./gallery')

module.exports = Backbone.Model.extend
	defaults :
		selectedFolder: null
		selectedGallery: null
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
				for idphoto in gallery.Photos
					p = this.photos.get(idphoto)
					g.addPhoto p
				f.Galleries.add g

	selectFolder: (id) ->
		this.set({selectedFolder: this.folders.get(id)})

	selectGallery: (id) ->
		selectedFolder = this.get 'selectedFolder'
		this.set {selectedGallery: id}
