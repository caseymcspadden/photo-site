# Folder model contains a collection of galleries

Backbone = require 'backbone'
Galleries = require './galleries'

module.exports = Backbone.Model.extend
	defaults :
		Name: ""
		Galleries: null
	initialize: (attributes, options) ->
		this.Galleries = new Galleries()