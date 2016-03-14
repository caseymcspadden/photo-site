#Folders View manages a collection of folders

#Dragula = require 'dragula'
Backbone = require 'backbone'
templates = require './jst'
Folders = require './folders'
Folder = require './folder'
Gallery = require './gallery'
Admin = require './admin'


module.exports = Backbone.View.extend
	$tree: null
	collapsed: true
	close_same_level: false
	duration: 400
	listAnim: true

	events:
		'click .add-folder': 'addFolder'
		#'click .add-gallery': 'addGallery'
		'click .folder-icon' : 'folderIconClicked'
		'click .folder-name' : 'folderNameClicked'
		'click .gallery-name' : 'galleryClicked'
		'submit #afv-addFolder form' : 'addFolder'
		'click .delete-folder' : 'deleteFolder'
		'mousedown' : 'mouseDown'
		'mouseup' : 'mouseUp'
		'mouseleave' : 'mouseUp'
		'mousemove a' : 'mouseMove'
		'mouseover a' : 'mouseOver'
		'mouseout a' : 'mouseOut'
		#'keypress': 'deleteFolder'

	initialize: (options) ->
		this.template = templates['admin-folders-view']
		this.folder_node_template = templates['folder-node-view']
		this.gallery_node_template = templates['gallery-node-view']
		this.dragElement = null
		this.dragStarted = false
		this.allowDrop = 0

		this.$el.html(this.template());
		this.$tree = this.$('.mtree');
		#this.listenTo(this.model.folders, 'add', this.folderAdded)
		#this.listenTo(this.model.folders, 'remove', this.folderRemoved)
		this.listenTo(this.model.folders, 'reset', this.resetFolders)
		this.listenTo(this.model.galleries, 'add', this.galleryAdded)
		this.listenTo(this.model.galleries, 'remove', this.galleryRemoved)
		this.listenTo(this.model.galleries, 'reset', this.resetGalleries)


	getContainingElement: (e, elementType) ->
		$e = $(e)
		while $e
			return $e if $e.is elementType
			$e = $e.parent()

	updateModelsFromTree: ($ul, idFolder) ->
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
			type = if $li.hasClass('gallery') then 'gallery' else 'folder'
			this.model.setDragModel $li.attr('id').replace(type+'-',''), type		
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
			type = if $li.hasClass('gallery') then 'gallery' else 'folder'
			this.allowDrop = this.model.allowDrop type, $li.attr('id').replace(type+'-','')
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

	addChildFolders: (idParent) ->
		children = this.model.folders.where {idfolder: idParent}
		for child in children
			this.addFolderToParent child.id, idParent
			this.addChildFolders child.id

	resetFolders: ->
		console.log "Reset folders"
		this.addChildFolders '0', 1

	resetGalleries: ->
		galleries = this.model.galleries.toArray()
		for gallery in galleries
			this.galleryAdded gallery
			#$li = this.$tree.find '#folder-' + gallery.get("idfolder")
			#el = this.gallery_node_template {id: gallery.id, name: gallery.get('name')}
			#$li.find('>ul').append el

	addFolderToParent: (id, idParent) ->
		f = this.model.folders.get id
		el = this.folder_node_template {id: id, name: f.get('name')}

		$li = this.$tree.find '#folder-'+idParent
		if $li.length==0
			this.$tree.append el
		else
			$li.find('>ul').append el

	folderAdded: (f) ->
		#this.listenTo(f.galleries, 'add', this.galleryAdded)
		#this.listenTo(f.galleries, 'remove', this.galleryRemoved)
		this.$tree.append('<li id="folder-' + f.id + '" class="folder mtree-node mtree-open"><a href="#">' + f.get('name') + '</a><ul id="container-' + f.id + '" class="mtree-level-1"></ul></li>')
		this.dragula.containers.push this.$tree.find('#container-'+f.id)[0]

	folderRemoved: (f) ->
		console.log "Folder Removed"
		this.$tree.find('#folder-' + f.id).remove()

	galleryAdded: (g) -> 
		$li = this.$tree.find '#folder-' + g.get("idfolder")
		el = this.gallery_node_template {id: g.id, name: g.get('name')}
		$li.find('>ul').append el

	galleryRemoved: (g) ->
		this.$tree.find('#gallery-' + g.id).remove()

	#photoRemoved: (p) ->
	#	console.log "photo removed from gallery"

	addFolder: (e) ->
		e.preventDefault()
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value
		this.model.createFolder data
		this.$('#afv-addFolder .close-button').trigger('click')

	deleteFolder: (e) ->
		selectedFolder = this.model.get 'selectedFolder'
		this.model.deleteFolder selectedFolder

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

	folderNameClicked: (e) ->
		$li = $(e.target).parent().parent()
		this.model.selectFolder $li.attr('id').replace(/^folder-/,'')
		this.model.selectGallery null
		this.$('.folder.mtree-active').not($li).removeClass('mtree-active')
		this.$('.gallery.mtree-active').removeClass('mtree-active')
		$li.addClass 'mtree-active'
		e.preventDefault()

	galleryClicked: (e) ->		
		$li = $(e.target).parent().parent()
		$folder = $li.parent().parent()

		this.$('.folder.mtree-active').not($folder).removeClass('mtree-active')
		$folder.addClass 'mtree-active'
		this.model.selectFolder $folder.attr('id').replace(/^folder-/,'')

		this.$('.gallery.mtree-active').not($li).removeClass('mtree-active')
		$li.addClass('mtree-active')
		this.model.selectGallery $li.attr('id').replace(/^gallery-/,'')

		e.preventDefault()




