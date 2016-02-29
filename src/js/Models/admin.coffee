Backbone = require 'backbone'
FolderCollection = require './folders'
PhotoCollection = require './photos'
Folder = require('./folder')
Gallery = require('./gallery')

module.exports = Backbone.Model.extend
	defaults:
		selectedFolder: null
		selectedGallery: null
		addingPhotos: false

	initialize: (attributes, options) ->
		this.folders = new FolderCollection
		this.photos = new PhotoCollection

		for folder in options.folders
			f = new Folder(folder)
			this.folders.add f   
			for gallery in folder.galleries
				g = new Gallery gallery,{master:this.photos}
				f.get('galleries').add g

	selectFolder: (id) ->
		this.set {selectedFolder: this.folders.get(id)}
		this.set {selectedGallery: null}
		this.set {addingPhotos: false}

	selectGallery: (id) ->
		console.log "Selecting gallery " + id
		selectedFolder = this.get 'selectedFolder'
		gallery = null
		if selectedFolder
			gallery = selectedFolder.get('galleries').get id
			if gallery
				gallery.populate()
		console.log gallery
		this.set {selectedGallery: gallery}
		this.set {addingPhotos: false}

	addSelectedPhotosToGallery: ->
		selectedGallery = this.get 'selectedGallery'
		return if !selectedGallery

		this.photos.each((photo) ->
			if photo.get('selected')
				photo.set {selected: false}
				selectedGallery.addPhoto(photo.id)
		)