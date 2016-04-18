Backbone = require 'backbone'
config = require './config'
Photo = require './photo'

module.exports = Backbone.Model.extend
	defaults:
		currentPhoto: null
		urlsuffix: ''

	initialize: ->
		this.photos = new Backbone.Collection null, {model: Photo}
		#this.listenTo this.photos, 'reset', this.photosLoaded
		self = this
		$.get(config.servicesBase + '/containerfrompath/' + document.location.pathname.replace(/^.*\/galleries\//,''), (data) ->
			self.set data
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