#Gallery View manages a gallery or folder

Backbone = require 'backbone'
templates = require './jst'
Folders = require './folders'
Folder = require './folder'
Gallery = require './gallery'
Admin = require './admin'

module.exports = Backbone.View.extend
	currentFolder: null

	events:
		'submit #fv-addGallery form' : 'addGallery'

	initialize: (options) ->
		this.template = templates['folder-view']
		this.listenTo this.model, 'change:selectedFolder', this.changeFolder

	addGallery: (e) ->
		e.preventDefault()
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value
		this.model.createGallery data
		this.$('#fv-addGallery .close-button').trigger('click')
	
	changeFolder: ->
		this.currentFolder = this.model.get 'selectedFolder'
		this.$('.title').html(if this.currentFolder then this.currentFolder.get('name') else 'Default')

	render: ->
		this.$el.html this.template {name: "Default"}
