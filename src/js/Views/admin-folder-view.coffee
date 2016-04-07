#Gallery View manages a gallery or folder

Backbone = require 'backbone'
templates = require './jst'
Containers = require './containers'
Container = require './container'
ContainerView = require './container-view'
EditContainerView = require('./edit-container-view')

module.exports = Backbone.View.extend
	currentContainer: null
	containerViews: {}

	events:
		'submit #fv-addGallery form' : 'addGallery'
		'click .featured-thumbnail' : 'selectContainer'

	initialize: (options) ->
		this.template = templates['admin-folder-view']
		this.listenTo this.model, 'change:selectedContainer', this.changeContainer
		this.listenTo this.model.containers, 'add remove change', this.addAll

	editFolder: (e) ->
		e.preventDefault()
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name] = elem.value
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
		console.log "folder container changed"
		if (this.currentContainer)
			this.stopListening this.currentContainer
		this.currentContainer = this.model.get 'selectedContainer'
		this.$('.title').html(if this.currentContainer then this.currentContainer.get('name') else 'Default')
		if (this.currentContainer)
			this.listenTo this.currentContainer, 'change' , this.currentContainerChanged
			this.addAll()

	render: ->
		this.$el.html this.template {name: 'Default'}
		this.editContainerView = new EditContainerView {el: '#fv-editFolder', model: this.model}
		this.editContainerView.render()
		this.addGalleryView = new EditContainerView {el: '#fv-addGallery', model: this.model, containerType: 'gallery'}
		this.addGalleryView.render()
  		
	addOne: (container) ->
		return if this.currentContainer==null or container.get('idparent') != this.currentContainer.id

		if !(this.containerViews.hasOwnProperty container.id)
			view = this.containerViews[container.id] = new ContainerView {model:container, className: 'featured-thumbnail', urlBase: this.model.urlBase}
			view.render()
		view = this.containerViews[container.id]
		view.delegateEvents()
		this.$('.gallery-list').append view.el

	addAll: ->
		this.$('.gallery-list').html ''
		this.model.containers.each this.addOne, this

	currentContainerChanged: (m) ->
		this.$('.title').html m.get('name')

	selectContainer: (e) ->
		this.model.selectContainer $(e.currentTarget).attr('id').replace('container-','')


