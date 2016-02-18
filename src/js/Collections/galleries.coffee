Backbone = require 'backbone'
Gallery = require './gallery'

module.exports = Backbone.Collection.extend
	url: "/"
	model: Gallery