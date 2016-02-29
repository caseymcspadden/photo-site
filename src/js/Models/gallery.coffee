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
		console.log options

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