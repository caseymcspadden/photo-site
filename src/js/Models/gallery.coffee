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
		this.set {photos: new Photos}
		this.set {master: options.photos}

	populate: ->
		#if this.get('populated') is false
		#	this.get('photos').fetch({reset: true})
		this.set {populated: true}

	addPhoto: (p) ->
		this.listenTo p, 'destroy', this.photoDestroyed
		this.get('photos').add p

	photoDestroyed: (p) ->
		this.get('photos').remove p
		#this.stopListening p

	getJSON: ->
		json = this.toJSON()
		json.photos = this.get('photos').toJSON()
		return json