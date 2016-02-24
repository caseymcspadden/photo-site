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
		this.set({photos: new PhotoCollection(options.photos)})
		this.set({folders: new FolderCollection()})

		for folder in options.folders
			f = new Folder(folder)
			this.get('folders').add f   
			for gallery in folder.galleries
				g = new Gallery(gallery)
				#for idphoto in gallery.photos
				#	p = this.get('photos').get(idphoto)
				#	g.addPhoto p
				f.get('galleries').add g

	selectFolder: (id) ->
		this.set {selectedFolder: this.get('folders').get(id)}
		this.set {selectedGallery: null}

	selectGallery: (id) ->
		selectedFolder = this.get 'selectedFolder'
		galllery = null
		if selectedFolder
			gallery = selectedFolder.get('galleries').get id
			if gallery
				gallery.populate()
		this.set {selectedGallery: gallery}