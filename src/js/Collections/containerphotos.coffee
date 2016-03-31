Backbone = require 'backbone'
Photo = require './photo'

module.exports = Backbone.Collection.extend
	model: Photo
	comparator: 'position'
