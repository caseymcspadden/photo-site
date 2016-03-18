Backbone = require 'backbone'
Photo = require './photo'
#Containers = require './containers'
ContainerPhotos = require './containerphotos'

module.exports = Backbone.Model.extend
	urlRoot: 'services/containers/'

	defaults :
		type: 'folder'	
		idparent: 0
		position: 0
		name: ""
		description: ""
		populated: false
		featuredPhoto: 0
	
	initialize: (attributes, options) ->
		#this.containers = new Backbone.Collection
		this.photos = new ContainerPhotos

	###
	removeContainer: (id) ->
		this.containers.remove id
		position = 1
		this.containers.each (c)->
			c.save {position: position++}

	addContainer: (c) ->
		this.containers.add c
		c.save {idParent: this.id, position: this.containers.length-1}
	###
	
	populate: ->
		self = this
		console.log 'populate'
		$.getJSON('services/containers/' + this.id + '/photos/', (data) ->
			_.each data, (id) ->
				self.addPhoto id
		)
		this.set {populated: true}

	featuredPhotoSource: ->
		if this.get('featuredPhoto') != 0 then 'photos/T/' + this.get('featuredPhoto') + '.jpg' else 'images/0_T.jpg'

	addPhoto: (id) ->
		p = this.master.get(id)
		this.photos.add p if p

	addPhotos: (arr) ->
		$.ajax(
			url: 'services/containers/' + this.id + '/photos/'
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
			url: 'services/containers/' + this.id + '/photos/'
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
			url: 'services/containers/' + this.id + '/photos/'
			type: 'PUT'
			context: this
			data: {ids: ids.join(',')}
		)

	setFeaturedPhoto: ->
		ids = this.getSelectedPhotos true
		return if ids.length==0
		this.save {featuredPhoto: ids[0]} , {wait: true	}
