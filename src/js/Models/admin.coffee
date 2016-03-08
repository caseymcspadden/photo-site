Backbone = require 'backbone'
FolderCollection = require './folders'
PhotoCollection = require './photos'
GalleryCollection = require './galleries'
Folder = require('./folder')
Gallery = require('./gallery')

module.exports = Backbone.Model.extend
	defaults:
		selectedFolder: null
		selectedGallery: null
		addingPhotos: false
		fetching: false

	initialize: (attributes, options) ->
		this.photos = new PhotoCollection
		this.folders = new FolderCollection
		this.galleries = new GalleryCollection

	fetchAll: ->
		self = this
		this.folders.fetch(
			success: (foldercollection) ->
				self.galleries.fetch(
					success: (gallerycollection) ->
						gallerycollection.each (g) ->
							g.master = self.photos
							folder = self.folders.get(g.get('idfolder'))
							folder.galleries.add g
						self.photos.fetch()
				)
		)

	createFolder: (data) ->
		this.folders.create data, {wait: true}

	deleteFolder: (folder) ->
		return if !folder
		toDelete = []
		folder.galleries.each (gallery) ->
			toDelete.push gallery

		for gallery in toDelete
			this.deleteGallery gallery

		this.folders.remove folder
		this.set {selectedFolder: null}
		folder.destroy()

	createGallery: (data) ->
		selectedFolder = this.get 'selectedFolder'
		if selectedFolder
			console.log 'creating'
			console.log data
			data.idfolder = selectedFolder.id
			g = this.galleries.create data, {wait: true}
			g.master = this.photos
			selectedFolder.galleries.add g

	deleteGallery: (gallery) ->
		return if !gallery
		folder = this.folders.get gallery.get('idfolder')
		folder.galleries.remove gallery
		this.galleries.remove gallery
		this.set {selectedGallery: null}
		gallery.destroy()

	selectFolder: (id) ->
		this.set {selectedFolder: this.folders.get(id)}
		this.set {selectedGallery: null}
		this.set {addingPhotos: false}

	selectGallery: (id) ->
		gallery = this.galleries.get id
		return if !gallery

		this.set {selectedFolder : this.folders.get(gallery.get('idfolder'))}
		this.set {selectedGallery : gallery}

		gallery.populate()

		this.set {addingPhotos: false}

	moveGallery: (obj) ->
		fromFolder = this.folders.get(obj.from.id)
		toFolder = this.folders.get(obj.to.id)

		fromFolder.galleries.reset()
		toFolder.galleries.reset()

		position = 1
		for id in obj.from.galleries
			g = this.galleries.get id
			g.save {idfolder: obj.from.id, position: position++}
			fromFolder.galleries.add g

		position = 1
		for id in obj.to.galleries
			g = this.galleries.get id
			g.save {idfolder: obj.to.id, position: position++}
			toFolder.galleries.add g

	addPhotos: (photos) ->
		for photo in photos
			this.photos.add photo

	addSelectedPhotosToGallery: (gallery) ->
		selectedPhotos = []

		this.photos.each((photo) ->
			if photo.get('selected')
				photo.set {selected: false}
				selectedPhotos.push photo.id
		)

		gallery.addPhotos selectedPhotos