# Gallery model contains a collection of photos

Backbone = require 'backbone'
Photo = require './photo'
Photos = require './photos'

module.exports = Backbone.Model.extend
	defaults :
		name: ""
		populated: false
		featuredPhoto: ""
	
	initialize: (attributes, options) ->
		this.photos = new Photos
		this.master = options.master

	populate: ->
		#if this.get('populated') is false
		#	this.get('photos').fetch({reset: true})
		self = this
		console.log 'populate'
		$.getJSON('services/galleries/' + this.id + '/photos/', (data) ->
			_.each data, (id) ->
				self.addPhoto id
		)
		this.set {populated: true}

	addPhoto: (id) ->
		p = this.master.get(id)
		this.photos.add p if p

	addPhotos: (arr) ->
		$.ajax(
			url: 'services/galleries/' + this.id + '/photos/'
			type: 'POST'
			context: this
			data: {ids: arr.join(',')}
			success: (result) ->
				json = $.parseJSON(result)
				ids = json.ids.split ','
				for id in ids
					this.addPhoto id
		)

	deletePhotos: (arr) ->
		$.ajax(
			url: 'services/galleries/' + this.id + '/photos/'
			type: 'DELETE'
			context: this
			data: {ids: arr.join(',')}
			success: (result) ->
				json = $.parseJSON(result)
				ids = json.ids.split ','
				for id in ids
					this.photos.remove id
		)