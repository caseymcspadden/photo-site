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