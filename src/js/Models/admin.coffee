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
				f.galleries.add g

	selectFolder: (id) ->
		this.set {selectedFolder: this.folders.get(id)}
		this.set {selectedGallery: null}
		this.set {addingPhotos: false}

	selectGallery: (id) ->
		selectedFolder = this.get 'selectedFolder'
		gallery = null
		if selectedFolder
			gallery = selectedFolder.galleries.get id
			if gallery
				gallery.populate()
		this.set {selectedGallery: gallery}
		this.set {addingPhotos: false}

	addPhotos: (photos) ->
		for photo in photos
			this.photos.add photo

	addSelectedPhotosToGallery: ->
		selectedGallery = this.get 'selectedGallery'
		return if !selectedGallery

		selectedPhotos = []

		this.photos.each((photo) ->
			if photo.get('selected')
				photo.set {selected: false}
				selectedPhotos.push photo.id
		)

		selectedGallery.addPhotos selectedPhotos

	removeSelectedPhotosFromGallery: ->
		selectedGallery = this.get 'selectedGallery'
		return if !selectedGallery

		selectedPhotos = []

		selectedGallery.photos.each((photo) ->
			if photo.get('selected')
				photo.set {selected: false}
				selectedPhotos.push photo.id
				#self.photos.add photo
		)

		selectedGallery.deletePhotos selectedPhotos