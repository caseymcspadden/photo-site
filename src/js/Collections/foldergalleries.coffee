Backbone = require 'backbone'
Gallery = require './gallery'

module.exports = Backbone.Collection.extend
	model: Gallery
	url: "services/galleries/"
	comparator: (a, b) ->
		console.log 'comparing galleries'
		parseInt a.get('position') - parseInt b.get('position')