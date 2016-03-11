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
		#'click .add-folder': 'addFolder'
		#'click .add-gallery': 'addGallery'
		'click .folder-icon' : 'folderIconClicked'
		'click .folder-name' : 'folderNameClicked'
		'click .gallery-name' : 'galleryClicked'
		'submit #afv-addFolder form' : 'addFolder'
		'click .delete-folder' : 'deleteFolder'
		'mousedown' : 'mouseDown'
		'mouseup' : 'mouseUp'
		'mousemove' : 'mouseMove'
		'mouseenter a' : 'mouseEnter'
		'mouseleave a' : 'mouseLeave'
		#'keypress': 'deleteFolder'

	initialize: (options) ->
		this.template = templates['admin-folders-view']
		this.folder_node_template = templates['folder-node-view']
		this.gallery_node_template = templates['gallery-node-view']
		this.dragElement = null
		this.dropTarget = null
		this.mouseIsDown = false

		this.$el.html(this.template());

		this.$tree = this.$('.mtree');

		#this.listenTo(this.model.folders, 'add', this.folderAdded)
		#this.listenTo(this.model.folders, 'remove', this.folderRemoved)
		this.listenTo(this.model.folders, 'reset', this.resetFolders)
		#this.listenTo(this.model.galleries, 'add', this.galleryAdded)
		#this.listenTo(this.model.galleries, 'remove', this.galleryRemoved)
		this.listenTo(this.model.galleries, 'reset', this.resetGalleries)

		#this.dragula = Dragula()

		#self = this
		#this.dragula.on('drop', (el, target, source, sibling) ->
		#	console.log 'drop'
		#	fromFolder = $(source).attr('id').replace('container-','')
		#	toFolder = $(target).attr('id').replace('container-','')
			
			#obj = {}
			#fromGalleries = []
			#toGalleries = []

			#elements = $(source).find('li').toArray()
			#for e in elements
			#	fromGalleries.push $(e).attr('id').replace('gallery-','')

			#elements = $(target).find('li').toArray()
			#for e in elements
			#	toGalleries.push $(e).attr('id').replace('gallery-','')

			
			#self.model.moveGallery {from: {id: fromFolder, galleries: fromGalleries}, to: {id:toFolder, galleries: toGalleries}}
		#)

	getContainingElement: (e)->
		$e = $(e)
		while $e
			return $e if $e.is('li')
			$e = $e.parent()

	mouseDown: (e) ->
		this.mouseIsDown = true
		e.preventDefault()

	mouseUp: (e) ->
		this.mouseIsDown = false
		this.dragElement = null
		this.$('li').removeClass('droptarget')

	mouseEnter: (e) ->
		if this.dragElement != null
			$li = this.getContainingElement e.target
			id = $li.attr('id')
			console.log id
			if $li and $li.hasClass('folder') and this.dragElement.find('#'+id).length==0
				$li.addClass('droptarget')

	mouseLeave: (e) ->
		if this.dragElement != null
			this.$('li').removeClass('droptarget')

	mouseMove: (e) ->
		if this.mouseIsDown and this.dragElement==null
			this.dragElement = this.getContainingElement e.target
		e.preventDefault() 

	dragEnter: (e) ->
		console.log "dragenter"
		console.log e.currentTarget
		#$li = this.getContainingElement e.target
		#return true if this.dropTarget and $li.attr('id') == this.dropTarget.attr('id')
		#console.log "Drag Enter"
		#$li.addClass('dragover') if $li
		#this.dropTarget.removeClass('dragover') if this.dropTarget and this.dropTarget.attr('id') != $li.attr('id')
		#this.dropTarget = $li
		#e.preventDefault()
		#true

	dragLeave: (e) ->
		console.log "Leaving"
		console.log e.target
		#console.log 'allowDrop'
		#$li = this.getContainingElement e.target
		#$li.removeClass('dragover') if $li
		#e.preventDefault()

	dragStart: (e) ->
		#this.dragElement = this.getContainingElement e.target
		console.log 'dragstart' 
		console.log e.target

	dragEnd: (e) ->
		console.log 'dragend'
		#this.$('li').removeClass('dragover')
		#console.log e
		#e.preventDefault()

	drop: (e) ->
		console.log 'drop' 
		#this.$('li').removeClass('dragover')
		#console.log e
		#e.preventDefault()

	render: ->
		this.$tree.html('')
		#this.model.folders.each (folder) ->
		#	self.model.set({selectedFolder: folder})
		#	self.folderAdded folder
		#	folder.galleries.each (gallery) ->
		#		self.galleryAdded(gallery)

		#this.$tree.find('ul').css
		#	'overflow':'hidden'
		#	'height': if this.collapsed then 0 else 'auto'
		#	'display': if this.collapsed then 'none' else 'block'

	addChildFolders: (idParent) ->
		children = this.model.folders.where {idfolder: idParent}
		for child in children
			console.log 'parent ' + idParent + ' has child ' + child.id
			this.testAddFolder child.id, idParent
			this.addChildFolders child.id

	resetFolders: ->
		console.log "Reset folders"
		this.addChildFolders '0', 1

	resetGalleries: ->
		galleries = this.model.galleries.toArray()
		for gallery in galleries
			$li = this.$tree.find '#folder-' + gallery.get("idfolder")
			el = this.gallery_node_template {id: gallery.id, name: gallery.get('name')}
			$li.find('>ul').append el

	testAddFolder: (id, idParent) ->
		f = this.model.folders.get id
		el = this.folder_node_template {id: id, name: f.get('name')}

		$li = this.$tree.find '#folder-'+idParent
		if $li.length==0
			this.$tree.append el
		else
			$li.find('>ul').append el

		#this.dragula.containers.push this.$tree.find('#container-'+id)[0]

	folderAdded: (f) ->
		#this.listenTo(f.galleries, 'add', this.galleryAdded)
		#this.listenTo(f.galleries, 'remove', this.galleryRemoved)
		#this.dragula.containers.push this.$tree.append('<li id="folder-' + f.id + '" class="folder mtree-node mtree-open"><a href="#">' + f.get('name') + '</a><ul class="mtree-level-1"></ul></li>')
		this.$tree.append('<li id="folder-' + f.id + '" class="folder mtree-node mtree-open"><a href="#">' + f.get('name') + '</a><ul id="container-' + f.id + '" class="mtree-level-1"></ul></li>')
		#this.dragula.containers.push this.$tree.find('#folder-'+f.id)[0]
		this.dragula.containers.push this.$tree.find('#container-'+f.id)[0]
		#this.dragula.containers.push $li.find('ul')[0]
		#console.log this.dragula.containers

	folderRemoved: (f) ->
		console.log "Folder Removed"
		this.$tree.find('#folder-' + f.id).remove()

	galleryAdded: (g) -> 
		#this.listenTo g.photos, 'remove', this.photoRemoved
		folder = this.model.folders.get g.get('idfolder')
		#sel = this.model.get('selectedFolder')
		this.$('#folder-' + folder.id + ' ul').append('<li id="gallery-' + g.id + '" class="gallery" draggable="true"><a href="#">' + g.get('name') + '</a></li>')

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




