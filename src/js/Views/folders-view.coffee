#Folders View manages a collection of folders

Backbone = require 'backbone'
templates = require './jst'
Folders = require './folders'
Folder = require './folder'
Gallery = require './gallery'

module.exports = Backbone.View.extend
	initfolders: []
	selectedFolder: null
	selectedGallery: null
	$tree: null
	events:
		'click .add-folder': 'addFolder'
		'click .add-gallery': 'addGallery'
		'click li > *:first-child' : 'test1'
		'click .folder > *:first-child' : 'folderClicked'
		'click .gallery > *:first-child' : 'galleryClicked'

	initialize: (options) ->
		this.template = templates['folders-view']

		this.$el.html(this.template());

		this.$tree = this.$('.mtree');

		console.log this.$tree

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

	folderAdded: (f) ->
		console.log "Folder Added"
		this.selectedFolder = f.cid
		console.log f
		test = this.$tree.append('<li id="folder-' + f.cid + '" class="folder mtree-node mtree-closed"><a href="#">' + f.get('Name') + '</a><ul class="mtree-level-1"></ul></li>')
		console.log(test);		

	folderRemoved: (f) ->
		console.log "Folder Removed"

	galleryAdded: (g) -> 
		console.log "Gallery Added"
		console.log g
		this.$('#folder-' + this.selectedFolder + ' ul').append('<li id="gallery-' + g.cid + '" class="gallery"><a href="#">' + g.get('Name') + '</a></li>')

	galleryRemoved: (g) ->
		console.log g

	addFolder: ->
		console.log "Add Folder"
		this.collection.add(new Folder({Name: 'New Folder'}))

	addGallery: ->
		console.log "Add Gallery"

	test1: ->
		console.log "test1 called"

	folderClicked: ->
		console.log "folder clicked"

	galleryClicked: ->
		console.log "gallery clicked"