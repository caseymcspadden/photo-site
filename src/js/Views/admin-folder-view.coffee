#Gallery View manages a gallery or folder

BaseView = require './base-view'
templates = require './jst'
Containers = require './containers'
Container = require './container'
ContainerView = require './container-view'

module.exports = BaseView.extend
	currentContainer: null
	containerViews: {}

	events:
		'click .featured-thumbnail' : 'selectContainer'
		'click .edit-folder' : 'editFolder'
		'click .add-gallery' : 'addGallery'
		'click .delete-folder' : 'deleteFolder'

	initialize: (options) ->
		this.template = templates['admin-folder-view']
		this.listenTo this.model, 'change:selectedContainer', this.changeContainer
		this.listenTo this.model.containers, 'add remove change', this.addAll

	changeContainer: ->
		if (this.currentContainer)
			this.stopListening this.currentContainer
		this.currentContainer = this.model.get 'selectedContainer'
		this.$('.title').html(if this.currentContainer then this.currentContainer.get('name') else 'Default')
		if (this.currentContainer)
			this.listenTo this.currentContainer, 'change' , this.currentContainerChanged
			this.addAll()

	editFolder: (e) ->
		this.model.set 'newContainerType', null
		this.model.toggleValue 'editContainerToggle'

	addGallery: (e) ->
		this.model.set 'newContainerType', 'gallery'
		this.model.toggleValue 'editContainerToggle'

	deleteFolder: ->
		this.model.deleteContainer this.currentContainer

	render: ->
		this.$el.html this.template {name: 'Default'}
  		
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


