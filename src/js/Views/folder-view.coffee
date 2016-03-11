#Gallery View manages a gallery or folder

Backbone = require 'backbone'
templates = require './jst'
Folders = require './folders'
Folder = require './folder'
Gallery = require './gallery'
Admin = require './admin'
FeaturedView = require './featured-view'

module.exports = Backbone.View.extend
	currentFolder: null
	featuredViews: {}

	events:
		'submit #fv-editFolder form' : 'editFolder'
		'submit #fv-addGallery form' : 'addGallery'
		'click .featured-thumbnail' : 'galleryClicked'

	initialize: (options) ->
		this.template = templates['folder-view']
		this.listenTo this.model, 'change:selectedFolder', this.changeFolder
		this.listenTo this.model.galleries, 'remove', this.addAll
		this.listenTo this.model.galleries, 'add', this.addAll

	editFolder: (e) ->
		console.log e

	addGallery: (e) ->
		e.preventDefault()
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value
		this.model.createGallery data
		this.$('#fv-addGallery .close-button').trigger('click')
	
	changeFolder: ->
		if (this.currentFolder)
			this.stopListening this.currentFolder.galleries

		this.currentFolder = this.model.get 'selectedFolder'
		this.$('.title').html(if this.currentFolder then this.currentFolder.get('name') else 'Default')
		if (this.currentFolder)
			this.$("#fv-editFolder input[name='name']").val this.currentFolder.get('name')
			this.$("#fv-editFolder input[name='description']").val this.currentFolder.get('description')
			this.listenTo this.currentFolder.galleries ,'sort' , this.addAll
			this.addAll()

	render: ->
		this.$el.html this.template {name: 'Default'}
  		
	addOne: (gallery) ->
		if !(this.featuredViews.hasOwnProperty gallery.id)
			view = this.featuredViews[gallery.id] = new FeaturedView {model:gallery, className: 'featured-thumbnail'}
			view.render()
		view = this.featuredViews[gallery.id]
		view.delegateEvents()
		this.$('.gallery-list').append view.el

	addAll: ->
		console.log "Add all"
		this.$('.gallery-list').html ''
		if this.currentFolder
			this.currentFolder.galleries.each this.addOne, this

	galleryClicked: (e) ->
		console.log e


