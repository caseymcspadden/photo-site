#Folders View manages a collection of folders

Backbone = require 'backbone'
templates = require './jst'
Folders = require './folders'
Folder = require './folder'
Gallery = require './gallery'
Admin = require './admin'

module.exports = Backbone.View.extend
	admin: null
	$tree: null
	collapsed: true
	close_same_level: false
	duration: 400
	listAnim: true

	events:
		'click .add-folder': 'addFolder'
		'click .add-gallery': 'addGallery'
		'click .folder > *:first-child' : 'folderClicked'
		'click .gallery > *:first-child' : 'galleryClicked'

	initialize: (options) ->
		this.template = templates['admin-folders-view']

		this.admin = options.admin

		this.$el.html(this.template());

		this.$tree = this.$('.mtree');

		this.listenTo(this.admin.folders, 'add', this.folderAdded)
		this.listenTo(this.admin.folders, 'remove', this.folderRemoved)
			
	render: ->
		this.$tree.html('');
		self = this
		this.admin.folders.each (folder) ->
			self.admin.set({selectedFolder: folder})
			self.folderAdded folder
			folder.get('galleries').each (gallery) ->
				self.galleryAdded(gallery)

		this.$tree.find('ul').css
			'overflow':'hidden'
			'height': if this.collapsed then 0 else 'auto'
			'display': if this.collapsed then 'none' else 'block'

	folderAdded: (f) ->
		this.listenTo(f.get('galleries'), 'add', this.galleryAdded)
		this.listenTo(f.get('galleries'), 'remove', this.galleryRemoved)
		this.$tree.append('<li id="folder-' + f.cid + '" class="folder mtree-node mtree-closed"><a href="#">' + f.get('name') + '</a><ul class="mtree-level-1"></ul></li>')

	folderRemoved: (f) ->
		console.log "Folder Removed"

	galleryAdded: (g) -> 
		this.listenTo(g.get('photos'), 'remove', this.photoRemoved)
		sel = this.admin.get('selectedFolder')
		this.$('#folder-' + sel.cid + ' ul').append('<li id="gallery-' + g.cid + '" class="gallery" draggable="true"><a href="#">' + g.get('name') + '</a></li>')

	galleryRemoved: (g) ->
		console.log 'Gallery Removed'

	photoRemoved: (p) ->
		console.log "photo removed from gallery"

	addFolder: ->
		this.admin.folders.add(new Folder({name: 'New Folder'}))

	addGallery: ->
		$active = this.$('.folder.mtree-active')
		if $active.length > 0
			sel = this.admin.get 'selectedFolder'
			sel.get('galleries').add new Gallery({name: 'New Gallery'})
			isOpen = $active.hasClass 'mtree-open'
			this.setNodeClass $active, false

			$ul = $active.children('ul').first()
			if $ul.children().length > 0 and not isOpen
				$ul.slideToggle(this.duration)
			cid = $active.attr('id').replace(/^folder-/,'')
			this.admin.selectFolder cid

	setNodeClass: (elem, isOpen) ->
		if isOpen
			elem.removeClass('mtree-open').addClass('mtree-closed')
		else
			elem.removeClass('mtree-closed').addClass('mtree-open')

	openFolder: ($li) ->
		this.admin.selectFolder $li.attr('id').replace(/^folder-/,'')
		this.admin.selectGallery null
		
		this.$('.folder.mtree-active').not($li).removeClass('mtree-active')
		$li.addClass 'mtree-active'

		$ul = $li.children('ul').first()
		isOpen = $li.hasClass('mtree-open')

		$ul.css
			'height': 'auto'

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
		this.admin.selectFolder $folder.attr('id').replace(/^folder-/,'')

		this.$('.gallery.mtree-active').not($li).removeClass('mtree-active')
		$li.addClass('mtree-active')
		this.admin.selectGallery $li.attr('id').replace(/^gallery-/,'')

		e.preventDefault()




