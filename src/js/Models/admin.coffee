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
		targetType = target.get 'type'
		dragType = dragmodel.get 'type'

		return 0 if dragmodel == target
		return 2 if targetType == 'gallery' and dragType == 'gallery'
		return 0 if dragType=='folder' and this.isDescendantContainer target, dragmodel
		return 3 if targetType=='folder' and dragType == 'folder'
		if targetType == 'folder' and dragType == 'gallery'
			return 2 if dragmodel.get('idparent') == id
			return 3
		return 2 if targetType == 'gallery' and dragType == 'folder'
		#if target.get('type') == 'gallery' and dragmodel.get('type') == 'folder'
		#	position = target.get 'position'
		#	return 2 if position <= 1
		0
	
	moveContainerTo: (container, toId, before)->
		toContainer = this.containers.get toId

		if before
			children = this.containers.where {idparent: toContainer.get('idparent')}
			position = 1
			for child in children 
				if child.id == toId
					container.save {position: position++}
				if child.id != container.id
					child.save {position: position++}
			container.save {idparent: toContainer.get('idparent')}
		else
			children = this.containers.where {idparent: toId}
			container.save {idparent: toId, position: children.length+1}

		this.adjustPositions()

	adjustPositions: ->
		children = _.sortBy (this.containers.where { idparent: 0}) , (m) ->
			m.get('position')

		position = 1
		for child in children 
			child.save {position: position++}

		this.containers.each (container) ->
			position = 1
			children = _.sortBy (this.containers.where { idparent: container.id }), (m) ->
				m.get('position')
			for child in children 
				child.save {position: position++}
		, this
	
	fetchAll: ->					
		self = this
		this.containers.fetch(
			reset: true
			success: (containercollection) ->
				containercollection.each (c) ->
					c.master = self.photos
					#idParent = c.get('idparent')
					#console.log idParent
					#if idParent != 0
					#	container = self.containers.get idParent
					#	container.containers.add c
				self.photos.fetch()
		)

	createContainer: (data) ->
		selectedContainer = this.get 'selectedContainer'
		data.idparent = if (selectedContainer and selectedContainer.get('type')=='folder') then selectedContainer.id else 0
		c = this.containers.create data, {wait: true}
		c.master = this.photos

	deleteContainer: (container) ->
		this.containers.remove container
		this.set {selectedContainer: null}
		container.destroy()
		this.adjustPositions()

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