Backbone = require 'backbone'
Photo = require './photo'

module.exports = Backbone.Collection.extend
	url: "/"
	model: Photo
