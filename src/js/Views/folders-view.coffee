#Folders View manages a collection of folders

Backbone = require 'backbone'
templates = require './jst'
Folders = require './folders'
Folder = require './folder'
Gallery = require './gallery'

module.exports = Backbone.View.extend
	initfolders: []
	events:
		'click .add-folder': 'addFolder'
		'click .add-gallery': 'addGallery'
		'click li > *:first-child' : 'test1'

	initialize: (options) ->
		this.template = templates['folders-view']

		console.log options.initfolders

		this.collection = new Folders()

		this.listenTo(this.collection, 'add', this.folderAdded)
		this.listenTo(this.collection, 'remove', this.folderRemoved)

		for folder in options.initfolders
		  f = new Folder(folder)
		  this.listenTo(f.Galleries, 'add', this.galleryAdded)
		  this.listenTo(f.Galleries, 'remove', this.galleryRemoved)
		  this.collection.add f		
		  for gallery in folder.Galleries
		    f.Galleries.add new Gallery(gallery)
			
	render: ->
		console.log this.collection.toJSON()
		this.$el.html this.template(this.collection.toJSON())

	folderAdded: ->
		console.log "Folder Added"

	folderRemoved: ->
		console.log "Folder Removed"

	galleryAdded: (g) -> 
		console.log "Gallery Added"
		console.log g

	galleryRemoved: (g) ->
		console.log g

	addFolder: ->
		console.log "Add Folder"

	addGallery: ->
		console.log "Add Gallery"

	test1: ->
		console.log "test1 called"