Backbone = require 'backbone'
Gallery = require './gallery'

module.exports = Backbone.Collection.extend
	model: Gallery
	url: "services/galleries/"
	comparator: 'position'
