#Folders View manages a collection of folders

#Dragula = require 'dragula'
Backbone = require 'backbone'
templates = require './jst'
Container = require './container'
Containers = require './containers'
NodeView = require './node-view'
#ViewModel = require './viewmodel'


module.exports = Backbone.View.extend
	$tree: null
	collapsed: true
	close_same_level: false
	duration: 400
	listAnim: true

	events:
		'submit #afv-addFolder form' : 'addFolder'
		'click .folder-icon' : 'folderIconClicked'
		'click .node-name' : 'selectContainer'
		'submit #afv-addFolder form' : 'addFolder'
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

	mouseDown: (e) ->
		$li = this.getContainingElement e.target, 'li'
		this.dragStarted = false
		if $li
			this.dragElement = $li
			this.model.setDragModel $li.attr('id').replace('node-','')
		e.preventDefault()

	mouseUp: (e) ->
		e.preventDefault()
		this.$('li').removeClass('dropinside').removeClass('dropbefore')
		dragmodel = this.model.get('dragModel')
		if this.allowDrop!=0 && dragmodel
			this.dragElement.remove()
			$li = this.getContainingElement e.target, 'li'
			toId = parseInt $li.attr('id').replace('node-','')
			if e.offsetY < 15 and (this.allowDrop & 2)
				console.log "drop " + this.dragElement.attr('id') + ' before ' + $li.attr('id')
				this.dragElement.insertBefore $li
				this.model.moveContainerTo dragmodel, toId, true
			else if e.offsetY >= 15 and (this.allowDrop & 1)
				console.log "drop " + this.dragElement.attr('id') + ' inside ' + $li.attr('id')
				$li.find('>ul').append this.dragElement
				this.model.moveContainerTo dragmodel, toId, false

		this.dragStarted = false
		this.allowDrop = 0
		this.model.setDragModel 0
		this.dragElement = null

	mouseOver: (e) ->
		if this.model.get('dragModel') != null
			$li = this.getContainingElement e.target, 'li'
			this.allowDrop = this.model.allowDrop $li.attr('id').replace('node-','')
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
			this.addChildToParent child.id
			this.addChildContainers child.id

	resetContainers: ->
		console.log "Reset containers"
		this.addChildContainers 0

	addChildToParent: (id) ->
		container = this.model.containers.get id
		idParent = container.get('idparent')

		view = new NodeView {model: container}
		el = view.render().el

		$li = this.$tree.find '#node-'+idParent
		if $li.length==0
			this.$tree.append el
		else
			$li.find('>ul').append el

	containerAdded: (c) ->
		this.addChildToParent c.id

	containerRemoved: (c) ->
		this.$tree.find('#node-' + c.id).remove()

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
		$li = this.getContainingElement e.target, 'li'
		$ul = $li.children('ul').first()
		if $ul.children().length > 0
			isOpen = $li.hasClass('mtree-open')
			this.setNodeClass($li, isOpen)
			$ul.slideToggle(this.duration)
		e.preventDefault()

	selectContainer: (e) ->
		$li = this.getContainingElement e.target, 'li'
		this.model.selectContainer $li.attr('id').replace('node-','')
		e.preventDefault()

	selectedContainerChanged: (m) ->
		container = m.get 'selectedContainer'
		if container != null
			$li = this.$('#node-' + container.id)
			this.$('.mtree-node.mtree-active').not($li).removeClass('mtree-active')
			$li.addClass 'mtree-active'



