Backbone = require 'backbone'
config = require './config'
Photo = require './photo'

module.exports = Backbone.Model.extend
	defaults:
		currentPhoto: null
		urlsuffix: ''
		error: null
		archive: null

	initialize: ->
		this.photos = new Backbone.Collection null, {model: Photo}
		#this.listenTo this.photos, 'reset', this.photosLoaded
		self = this
		$.get(config.servicesBase + '/containerfrompath/' + document.location.pathname.replace(/^.*\/galleries\//,''), (data) ->
			self.set data
			self.id = data.id
			self.photos.url = config.servicesBase + '/containers/' + data.id + '/photos'
			self.photos.fetch {reset: true}
		)

	#photosLoaded: ->
		#this.set 'currentPhoto' , this.photos.at 0

	offsetCurrentPhoto: (offset) ->
		return if offset == 0
		photo = this.get "currentPhoto"
		return if !photo
		index = offset + this.photos.indexOf photo
		return if index<0 or index>=this.photos.length
		photo = this.photos.at index
		this.set 'currentPhoto', photo		
		photo.set 'selected', true

	createArchive: ->
		console.log 'creating archive'
		$.ajax(
			url: config.servicesBase + '/containers/' + this.id + '/archive'
			type: 'POST'
			context: this
			success: (json) ->
				console.log json
				if (json.error)
					this.set 'error', json.message
				else
					console.log 'setting archive'
					this.set 'archive' , json.archive
		)
