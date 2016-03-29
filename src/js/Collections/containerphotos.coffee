Backbone = require 'backbone'
PhotoSummary = require './photosummary'

module.exports = Backbone.Collection.extend
	model: PhotoSummary
