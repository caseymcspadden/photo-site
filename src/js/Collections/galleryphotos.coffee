Backbone = require 'backbone'
Photo = require './photo'

module.exports = Backbone.Collection.extend
	model: Photo
	url: 'services/photos/'
	comparator: (a, b) ->
		parseInt a.get('position') - parseInt b.get('position')