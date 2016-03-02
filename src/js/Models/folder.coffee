# Folder model contains a collection of galleries

Backbone = require 'backbone'
Gallery = require './gallery' 
Galleries = require './galleries'

module.exports = Backbone.Model.extend
	defaults :
		name: ""
	initialize: (options) ->
		console.log "Initializing folder"
		console.log options
		#this.galleries = new Galleries null , {url: 'services/folders/' + this.id + '/galleries/'}
		#this.galleries.fetch()