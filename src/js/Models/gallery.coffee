Backbone = require 'backbone'
config = require './config'
Photo = require './photo'

module.exports = Backbone.Model.extend
	defaults:
		currentPhoto: null
		urlsuffix: ''
		error: null
		archive: null
		archiveProgress: 0
		imagesize: 5
		access: 0
		maxdownloadsize: 0
		downloadgallery: 0
		buyprints: 0
		cancelArchive: false

	initialize: ->
		this.photos = new Backbone.Collection null, {model: Photo}
		#this.listenTo this.photos, 'reset', this.photosLoaded
		self = this
		$.get(config.servicesBase + '/containerfrompath/' + document.location.pathname.replace(/^.*\/galleries\//,''), (data) ->
			self.set data
			console.log data
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

	addPhotosToArchive: (startindex, count) ->
		return if startindex>=this.photos.length
		if this.get('cancelArchive')
			this.set 'archiveProgress', this.photos.length
			return

		add = [];
		end = Math.min(startindex+count,this.photos.length)
		add.push this.photos.at(i).id for i in [startindex...end]
		$.ajax(
			url: config.servicesBase + '/containers/' + this.id + '/archive/' + this.get('archive')
			type: 'PUT'
			context: this
			data: {ids: add.join(','), name: this.get('name').replace(/ /g,'-'), imagesize: this.get('imagesize')}
			success: (json) ->
				console.log json
				this.set 'archiveProgress' , json.count + this.get('archiveProgress')
				this.addPhotosToArchive(startindex+count, count)
		)

	createArchive: (imagesize) ->
		console.log 'creating archive'

		this.set 'archive', null
		this.set 'archiveProgress', 0
		this.set 'cancelArchive', false
		add = [];
		end = Math.min(10,this.photos.length)
		add.push this.photos.at(i).id for i in [0...end]
		$.ajax(
			url: config.servicesBase + '/containers/' + this.id + '/archive'
			type: 'POST'
			context: this
			data: {ids: add.join(','), name: this.get('name').replace(/ /g,'-'), imagesize: imagesize}
			success: (json) ->
				console.log json
				if (!json.error)
					this.set 'archive' , json.archive
					this.set 'imagesize' , json.imagesize
					this.set 'archiveProgress' , json.count + this.get('archiveProgress')
					this.addPhotosToArchive 10,10
				else
					this.set 'error', json.message
		)
