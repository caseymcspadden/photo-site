#Folders View manages a collection of folders

Dragula = require 'dragula'
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
		'click .folder > *:first-child' : 'folderClicked'
		'click .gallery > *:first-child' : 'galleryClicked'
		'submit #afv-addFolder form' : 'addFolder'
		'click .delete-folder' : 'deleteFolder'
		#'keypress': 'deleteFolder'

	initialize: (options) ->
		this.template = templates['admin-folders-view']

		this.$el.html(this.template());

		this.$tree = this.$('.mtree');

		this.listenTo(this.model.folders, 'add', this.folderAdded)
		this.listenTo(this.model.folders, 'remove', this.folderRemoved)
		this.listenTo(this.model.galleries, 'add', this.galleryAdded)
		this.listenTo(this.model.galleries, 'remove', this.galleryRemoved)

		this.dragula = Dragula()

		self = this
		this.dragula.on('drop', (el, target, source, sibling) ->
			id = $(el).attr('id').replace('gallery-','')
			fromFolder = $(source).attr('id').replace('container-','')
			toFolder = $(target).attr('id').replace('container-','')
			beforeGallery = if sibling==null then null else $(sibling).attr('id').replace('gallery-','')
			self.model.moveGallery id, fromFolder, toFolder, beforeGallery
		)

	render: ->
		this.$tree.html('')
		#this.model.folders.each (folder) ->
		#	self.model.set({selectedFolder: folder})
		#	self.folderAdded folder
		#	folder.galleries.each (gallery) ->
		#		self.galleryAdded(gallery)

		this.$tree.find('ul').css
			'overflow':'hidden'
			'height': if this.collapsed then 0 else 'auto'
			'display': if this.collapsed then 'none' else 'block'

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
		this.$tree.find('#folder-' + selectedFolder.id).remove()

	setNodeClass: (elem, isOpen) ->
		if isOpen
			elem.removeClass('mtree-open').addClass('mtree-closed')
		else
			elem.removeClass('mtree-closed').addClass('mtree-open')

	openFolder: ($li) ->
		this.model.selectFolder $li.attr('id').replace(/^folder-/,'')
		this.model.selectGallery null
		
		this.$('.folder.mtree-active').not($li).removeClass('mtree-active')
		$li.addClass 'mtree-active'

		$ul = $li.children('ul').first()
		isOpen = $li.hasClass('mtree-open')

		#$ul.css
		#	'height': 'auto'

		if $ul.children().length > 0
			this.setNodeClass($li, isOpen)
			$ul.slideToggle(this.duration)

	folderClicked: (e) ->
		$li = $(e.target).parent()
		this.openFolder $li
		e.preventDefault()

	galleryClicked: (e) ->
		$li = $(e.target).parent()
		$folder = $li.parent().parent()
		
		this.$('.folder.mtree-active').not($folder).removeClass('mtree-active')
		$folder.addClass 'mtree-active'
		this.model.selectFolder $folder.attr('id').replace(/^folder-/,'')

		this.$('.gallery.mtree-active').not($li).removeClass('mtree-active')
		$li.addClass('mtree-active')
		this.model.selectGallery $li.attr('id').replace(/^gallery-/,'')

		e.preventDefault()




