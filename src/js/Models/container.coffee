Backbone = require 'backbone'
Photo = require './photo'
ContainerPhotos = require './containerphotos'
config = require './config'

module.exports = Backbone.Model.extend
	urlRoot: -> 
		this.urlBase + '/services/containers'

	defaults :
		type: 'folder'	
		idparent: 0
		position: 0
		name: ""
		description: ""
		populated: false
		featuredPhoto: 0
		watermark: 1
		isportfolio: 0
	
	initialize: (attributes, options) ->
		this.urlBase = config.urlBase
		this.masterPhotoCollection = if options.collection then options.collection.masterPhotoCollection else null
		this.photos = new ContainerPhotos
	
	populate: ->
		self = this
		console.log 'populate'
		$.getJSON(this.urlBase + '/services/containers/' + this.id + '/photos', (data) ->
			_.each data, (id) ->
				self.addPhoto id
		)
		this.set {populated: true}
	
	addPhoto: (id) ->
		p = this.masterPhotoCollection.get(id)
		this.photos.add p if p

	addPhotos: (arr) ->
		$.ajax(
			url: this.urlBase +  '/services/containers/' + this.id + '/photos'
			type: 'POST'
			context: this
			data: {ids: arr.join(',')}
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

	removeSelectedPhotos: ->
		ids = this.getSelectedPhotos true
		$.ajax(
			url: this.urlBase + '/services/containers/' + this.id + '/photos'
			type: 'DELETE'
			context: this
			data: {ids: ids.join(',')}
			success: (result) ->
				json = $.parseJSON(result)
				ids = json.ids.split ','
				for id in ids
					this.photos.remove id
		)

	rearrangePhotos: (ids) ->
		index=0
		for id in ids
			this.photos.get(id).set {position: index++}
		this.photos.sort()

		$.ajax(
			url: this.urlBase + '/services/containers/' + this.id + '/photos'
			type: 'PUT'
			context: this
			data: {ids: ids.join(',')}
		)
