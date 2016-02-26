Backbone = require 'backbone'
Gallery = require './gallery'

module.exports = Backbone.Collection.extend
	url: "services/galleries/"
	model: Gallery