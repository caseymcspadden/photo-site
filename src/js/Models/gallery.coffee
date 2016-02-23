# Gallery model contains a collection of photos

Backbone = require 'backbone'
Photos = require './photos'

module.exports = Backbone.Model.extend
	defaults :
		Name: ""
		FeaturedPhoto: ""
		Photos: null
	initialize: (attributes, options) ->
		this.Photos = new Photos()

	addPhoto: (p) ->
		this.listenTo p, 'destroy', this.photoDestroyed
		this.Photos.add p

	photoDestroyed: (p) ->
		console.log 'photo destroyed'
		console.log p
		this.Photos.remove p
		#this.stopListening p
		console.log this.Photos

	getJSON: ->
		json = this.toJSON()
		json.Photos = this.Photos.toJSON()
		return json