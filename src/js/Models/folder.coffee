# Folder model contains a collection of galleries

Backbone = require 'backbone'
Gallery = require './gallery' 
Galleries = require './galleries'

module.exports = Backbone.Model.extend
	defaults :
		name: ''
		description: ''
	initialize: (options) ->
		this.galleries = new Galleries
