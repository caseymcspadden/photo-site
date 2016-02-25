#Gallery View manages a gallery or folder

Backbone = require 'backbone'
templates = require './jst'
Folders = require './folders'
Folder = require './folder'
Gallery = require './gallery'
Admin = require './admin'

module.exports = Backbone.View.extend
	admin: null
	currentFolder: null

	initialize: (options) ->
		this.template = templates['folder-view']

	changeFolder: (f) ->
		this.stopListening()
		this.currentFolder = f
		this.render()

	render: ->
		if this.currentFolder
			this.$el.html this.template(this.currentFolder.toJSON())