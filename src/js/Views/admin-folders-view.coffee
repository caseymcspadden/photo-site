#Folders View manages a collection of folders

#Dragula = require 'dragula'
Backbone = require 'backbone'
templates = require './jst'
Containers = require './containers'
Container = require './container'
NodeView = require './node-view'
Admin = require './admin'


module.exports = Backbone.View.extend
	$tree: null
	collapsed: true
	close_same_level: false
	duration: 400
	listAnim: true

	events:
		'submit #afv-addFolder form' : 'addFolder'
		'click .folder-icon' : 'folderIconClicked'
		'click .container' : 'selectContainer'
		#'submit #afv-addFolder form' : 'addFolder'
		'click .delete-folder' : 'deleteFolder'
		'mousedown .mtree' : 'mouseDown'
		'mouseup .mtree' : 'mouseUp'
		'mouseleave .mtree' : 'mouseUp'
		'mousemove a' : 'mouseMove'
		'mouseover a' : 'mouseOver'
		'mouseout a' : 'mouseOut'
		#'keypress': 'deleteFolder'

	initialize: (options) ->
		this.template = templates['admin-folders-view']
		this.dragElement = null
		this.dragStarted = false
		this.allowDrop = 0

		this.$el.html(this.template());
		this.$tree = this.$('.mtree');
		this.listenTo this.model, 'change:selectedContainer', this.selectedContainerChanged
		this.listenTo(this.model.containers, 'add', this.containerAdded)
		this.listenTo(this.model.containers, 'remove', this.containerRemoved)
		this.listenTo(this.model.containers, 'reset', this.resetContainers)

	getContainingElement: (e, elementType) ->
		$e = $(e)
		while $e
			return $e if $e.is elementType
			$e = $e.parent()

	updateModelsFromTree: ($ul, idContainer) ->
		console.log $ul

		arr = $ul.find('>li').toArray()
		folderPosition=0
		galleryPosition=0
		for li in arr
			collection = this.model.folders
			$li = $(li)
			id = 0
			isFolder = $li.hasClass 'folder'
			if isFolder
				id = $li.attr('id').replace('folder-','')
				folderPosition++
				console.log 'updating folder ' + id + ' with parent ' + idFolder + ' and position ' + folderPosition
			else
				id = $li.attr('id').replace('gallery-','')
				collection = this.model.galleries
				galleryPosition++
				console.log 'updating gallery ' + id + ' with parent ' + idFolder + ' and position ' + galleryPosition
			model = collection.get id
			model.save {idfolder: idFolder, position: if isFolder then folderPosition else galleryPosition}
			if isFolder
				this.updateModelsFromTree $li.find('>ul') , id

	mouseDown: (e) ->
		$li = this.getContainingElement e.target, 'li'
		this.dragStarted = false
		if $li
			this.dragElement = $li
			this.model.setDragModel $li.attr('id').replace('container-','')
		e.preventDefault()

	mouseUp: (e) ->
		e.preventDefault()
		this.$('li').removeClass('dropinside').removeClass('dropbefore')
		model = this.model.get('dragModel')
		if this.allowDrop!=0 && model
			this.dragElement.remove()
			$li = this.getContainingElement e.target, 'li'
			if e.offsetY < 15 and (this.allowDrop & 2)
				console.log "drop " + this.dragElement.attr('id') + ' before ' + $li.attr('id')
				this.dragElement.insertBefore $li
			else if e.offsetY >= 15 and (this.allowDrop & 1)
				console.log "drop " + this.dragElement.attr('id') + ' inside ' + $li.attr('id')
				if this.dragElement.hasClass('gallery') or $li.find('>ul >.gallery').length == 0
					$li.find('>ul').append this.dragElement
				else
					this.dragElement.insertBefore $li.find('>ul .gallery:first-child')
			this.updateModelsFromTree this.$tree , 0


		this.dragStarted = false
		this.allowDrop = 0
		this.model.setDragModel 0
		this.dragElement = null

	mouseOver: (e) ->
		if this.model.get('dragModel') != null
			$li = this.getContainingElement e.target, 'li'
			this.allowDrop = this.model.allowDrop $li.attr('id').replace('container-','')
		e.preventDefault()

	mouseOut: (e) ->
		this.$('li').removeClass('dropinside').removeClass('dropbefore')
		this.allowDrop = 0
		e.preventDefault()

	mouseMove: (e) ->
		e.preventDefault() 
		return if !this.model.get('dragModel')
		if !this.dragStarted
			console.log "starting drag"
			this.dragStarted = true

		return if this.allowDrop==0
		$li = this.getContainingElement e.target, 'li'
		if e.offsetY < 15 and (this.allowDrop & 2) and !$li.hasClass('dropbefore')
			$li.removeClass('dropinside').addClass('dropbefore')
		else if e.offsetY >= 15 and (this.allowDrop & 1) and !$li.hasClass('dropinside')
			$li.removeClass('dropbefore').addClass('dropinside')

	render: ->
		this.$tree.html('')

		#this.$tree.find('ul').css
		#	'overflow':'hidden'
		#	'height': if this.collapsed then 0 else 'auto'
		#	'display': if this.collapsed then 'none' else 'block'

	addChildContainers: (idParent) ->
		children = this.model.containers.where {idparent: idParent}
		for child in children
			this.addChildToParent child.id, idParent
			this.addChildContainers child.id

	resetContainers: ->
		console.log "Reset containers"
		this.addChildContainers '0'

	addChildToParent: (id, idParent) ->
		container = this.model.containers.get id

		view = new NodeView {model: container}
		el = view.render().el

		$li = this.$tree.find '#container-'+idParent
		if $li.length==0
			this.$tree.append el
		else
			$li.find('>ul').append el

	containerAdded: (c) ->
		this.addChildToParent f.id, 0

	containerRemoved: (c) ->
		console.log "Container Removed"
		this.$tree.find('#container-' + c.id).remove()

	addFolder: (e) ->
		e.preventDefault()
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value
		console.log data
		data.type = 'folder'
		this.model.createContainer data
		this.$('#afv-addFolder .close-button').trigger('click')

	deleteFolder: (e) ->
		selectedContainer = this.model.get 'selectedContainer'
		if selectedContainer.get('type') == 'folder'
			this.model.deleteContainer selectedContainer

	setNodeClass: (elem, isOpen) ->
		if isOpen
			elem.removeClass('mtree-open').addClass('mtree-closed')
			$(elem.find('.folder-icon')[0]).html '<i class="fa fa-folder"></i>'
		else
			elem.removeClass('mtree-closed').addClass('mtree-open')
			$(elem.find('.folder-icon')[0]).html '<i class="fa fa-folder-open"></i>'

	folderIconClicked: (e) ->
		$li = $(e.target).parent().parent().parent()
		$ul = $li.children('ul').first()
		if $ul.children().length > 0
			isOpen = $li.hasClass('mtree-open')
			this.setNodeClass($li, isOpen)
			$ul.slideToggle(this.duration)
		e.preventDefault()

	selectContainer: (e) ->
		$li = this.getContainingElement e.target, 'li'
		this.model.selectContainer $li.attr('id').replace('container-','')
		e.preventDefault()

	selectedContainerChanged: (m) ->
		container = m.get 'selectedContainer'
		if container != null
			$li = this.$('#container-' + container.id)
			this.$('.container.mtree-active').not($li).removeClass('mtree-active')
			$li.addClass 'mtree-active'



