Backbone = require 'backbone'
Photo = require './photo'
ContainerPhotos = require './containerphotos'
config = require './config'

module.exports = Backbone.Model.extend
	urlRoot: config.urlBase + '/services/containers'

	defaults :
		type: 'folder'	
		idparent: 0
		position: 0
		name: ''
		description: ''
		url: ''
		urlsuffix: ''
		access: 0
		populated: false
		featuredPhoto: 0
		watermark: 1
	
	initialize: (attributes, options) ->
		this.masterPhotoCollection = if options.collection then options.collection.masterPhotoCollection else null
		this.listenTo(this.masterPhotoCollection, 'remove', this.photoRemoved) if this.masterPhotoCollection
		this.photos = new ContainerPhotos
	
	populate: ->
		self = this
		console.log 'populate'
		$.getJSON(config.urlBase + '/services/containers/' + this.id + '/containerphotos', (data) ->
			_.each data, (id) ->
				self.addPhoto id
		)
		this.set {populated: true}

	photoRemoved: (photo) ->
		this.photos.remove photo
	
	addPhoto: (id) ->
		p = this.masterPhotoCollection.get(id)
		this.photos.add p if p

	addPhotos: (arr) ->
		addArray = []
		for id in arr
			addArray.push id if this.photos.indexOf(id)<0

		console.log addArray

		$.ajax(
			url: config.urlBase +  '/services/containers/' + this.id + '/containerphotos'
			type: 'POST'
			context: this
			data: {ids: addArray.join(',')}
			success: (result) ->
				json = $.parseJSON(result)
				ids = json.ids.split ','
				for id in ids
					this.addPhoto id
		)

	getSelectedPhotos: (resetSelected) ->
		ids = []

		this.photos.each((photo) ->
			if photo.get('selected')
				photo.set {selected: false} if resetSelected
				ids.push photo.id
		)
		ids

	removeSelectedPhotos: (deletePhotos) ->
		ids = this.getSelectedPhotos true

		collection = if deletePhotos then this.masterPhotoCollection else this.photos

		for id in ids
			collection.remove id

		url = if deletePhotos then '/photos' else '/containers/' + this.id + '/containerphotos'

		$.ajax(
			url: config.urlBase + '/services' + url
			type: 'DELETE'
			context: this
			data: {ids: ids.join(',')}
			success: (result) ->
				json = $.parseJSON(result)
				console.log json
		)

	rearrangePhotos: (ids) ->
		index=0
		for id in ids
			this.photos.get(id).set {position: index++}
		this.photos.sort()

		$.ajax(
			url: config.urlBase + '/services/containers/' + this.id + '/containerphotos'
			type: 'PUT'
			context: this
			data: {ids: ids.join(',')}
		)
