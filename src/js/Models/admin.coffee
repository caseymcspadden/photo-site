Backbone = require 'backbone'
PhotoCollection = require './photos'
Container = require './container'
Containers = require './containers'

module.exports = Backbone.Model.extend
	defaults:
		selectedContainer: null
		addingPhotos: false
		fetching: false
		dragModel: null

	initialize: (attributes, options) ->
		this.photos = new PhotoCollection
		this.containers = new Containers

	isDescendantContainer: (testChild, testParent) ->		
		while testChild
			idParent = testChild.get 'idparent'
			return true if idParent == testParent.id
			testChild = this.containers.get idParent
		false

	setDragModel: (id) ->
		if !id
			this.set {dragModel: null}
		else
			this.set {dragModel: this.containers.get id}

	allowDrop: (id) ->
		ret = 0
		target = this.containers.get id
		dragmodel = this.get 'dragModel'
		return 0 if dragmodel == target
		return 2 if target.get('type') == 'gallery' and dragmodel.get('type') == 'gallery'
		return 0 if dragmodel.get('type')=='folder' and this.isDescendantContainer target, dragmodel
		return 3 if target.get('type')=='folder' and dragmodel.get('type') == 'folder'
		if target.get('type') == 'folder' and dragmodel.get('type') == 'gallery'
			return 0 if dragmodel.get('idparent') == id
			return 1
		if target.get('type') == 'gallery' and dragmodel.get('type') == 'folder'
			position = target.get 'position'
			return 2 if position <= 1
		0

	fetchAll: ->					
		self = this
		this.containers.fetch(
			reset: true
			success: (containercollection) ->
				containercollection.each (c) ->
					c.master = self.photos
					idParent = c.get('idparent')
					if parseInt(idParent) != 0
						container = self.containers.get idParent
						container.containers.add c
				self.photos.fetch()
		)

	createContainer: (data) ->
		selectedContainer = this.get 'selectedContainer'
		data.idparent = if (selectedContainer and selectedContainer.get('type')=='folder') then selectedContainer.id else 0
		c = this.containers.create data, {wait: true}
		c.master = this.photos
		if (data.idparent)
			selectedContainer.containers.add c

	deleteContainer: (container) ->
		return if !container
		toDelete = []
		container.containers.each (c) ->
			toDelete.push c

		for c in toDelete
			this.deleteContainer c

		this.containers.remove container
		this.set {selectedContainer: null}
		container.destroy()

	#deleteGallery: (gallery) ->
	#	return if !gallery
	#	folder = this.folders.get gallery.get('idfolder')
	#	folder.galleries.remove gallery
	#	this.galleries.remove gallery
	#	this.set {selectedGallery: null}
	#	gallery.destroy()
	#	position = 1
	#	folder.galleries.each (g) ->
	#		g.save {position: position++}


	selectContainer: (id) ->
		container = this.containers.get id
		console.log container
		this.set {selectedContainer: container}
		this.set {addingPhotos: false}
		if container.get('type') == 'gallery'
			container.populate()

	#moveGallery: (obj) ->
	#	fromFolder = this.folders.get(obj.from.id)
	#	toFolder = this.folders.get(obj.to.id)

	#	fromFolder.galleries.reset()
	#	toFolder.galleries.reset()

	#	position = 1
	#	for id in obj.from.galleries
	#		g = this.galleries.get id
	#		g.save {idfolder: obj.from.id, position: position++}
	#		fromFolder.galleries.add g

	#	position = 1
	#	for id in obj.to.galleries
	#		g = this.galleries.get id
	#		g.save {idfolder: obj.to.id, position: position++}
	#		toFolder.galleries.add g

	addPhotos: (photos , addToSelectedContainer) ->
		container = this.get 'selectedContainer'
		added = []
		for photo in photos
			this.photos.add photo
			if addToSelectedContainer and container and container.get('type')=='gallery'
				added.push photo.id

		if added.length>0
			container.addPhotos added

	addSelectedPhotosToContainer: (container) ->
		selectedPhotos = []

		this.photos.each((photo) ->
			if photo.get('selected')
				photo.set {selected: false}
				selectedPhotos.push photo.id
		)

		container.addPhotos selectedPhotos