# Gallery model contains a collection of photos

Backbone = require 'backbone'
Photo = require './photo'
GalleryPhotos = require './galleryphotos'

module.exports = Backbone.Model.extend
	defaults :
		size: 'L'
		photo: null
		collection: null	
