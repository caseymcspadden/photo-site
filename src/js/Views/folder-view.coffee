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
		this.listenTo this.model, 'change:selectedFolder', this.changeFolder

	changeFolder: (f) ->
		this.currentFolder = this.model.get 'selectedFolder'
		this.render()

	render: ->
		if this.currentFolder
			this.$el.html this.template(this.currentFolder.toJSON())