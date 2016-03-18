#Gallery View manages a gallery or folder

Backbone = require 'backbone'
templates = require './jst'
Containers = require './containers'
Container = require './container'
Admin = require './admin'
FeaturedView = require './featured-view'

module.exports = Backbone.View.extend
	currentContainer: null
	featuredViews: {}

	events:
		'submit #fv-editFolder form' : 'editFolder'
		'submit #fv-addGallery form' : 'addGallery'
		'dblclick .featured-thumbnail' : 'selectGallery'

	initialize: (options) ->
		this.template = templates['folder-view']
		this.listenTo this.model, 'change:selectedContainer', this.changeContainer
		this.listenTo this.model.galleries, 'remove', this.addAll
		this.listenTo this.model.galleries, 'add', this.addAll

	editFolder: (e) ->
		e.preventDefault()
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value	
		this.currentContainer.save data
		this.$('#fv-editFolder .close-button').trigger('click')

	addGallery: (e) ->
		e.preventDefault()
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value
		data.type = 'gallery'
		this.model.createContainer data
		this.$('#fv-addGallery .close-button').trigger('click')
	
	changeContainer: ->
		if (this.currentContainer)
			this.stopListening this.currentContainer.containers

		this.currentContainer = this.model.get 'selectedContainer'
		this.$('.title').html(if this.currentContainer then this.currentContainer.get('name') else 'Default')
		if (this.currentContainer)
			this.$("#fv-editFolder input[name='name']").val this.currentContainer.get('name')
			this.$("#fv-editFolder input[name='description']").val this.currentContainer.get('description')
			this.listenTo this.currentContainer.containers ,'sort' , this.addAll
			this.addAll()

	render: ->
		this.$el.html this.template {name: 'Default'}
  		
	addOne: (container) ->
		return if container.get('type')=='folder'
		if !(this.featuredViews.hasOwnProperty container.id)
			view = this.featuredViews[container.id] = new FeaturedView {model:container, className: 'featured-thumbnail'}
			view.render()
		view = this.featuredViews[container.id]
		view.delegateEvents()
		this.$('.gallery-list').append view.el

	addAll: ->
		console.log "Add all"
		this.$('.gallery-list').html ''
		if this.currentContainer
			this.currentContainer.containers.each this.addOne, this

	selectGallery: (e) ->
		this.model.selectContainer $(e.currentTarget).attr('id').replace('featured-','')


